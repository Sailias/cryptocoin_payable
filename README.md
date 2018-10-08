# Cryptocoin Payable

Forked from [Bitcoin Payable](https://github.com/Sailias/bitcoin_payable)

A rails gem that enables any model to have crypto coin payments.
The polymorphic table coin_payments creates payments with unique addresses based on a BIP32 deterministic seed using https://github.com/wink/money-tree and uses external APIs to check for payments:

- https://etherscan.io
- https://www.blockcypher.com

Payments have 5 states:  `pending`, `partial_payment`, `paid_in_full`, `comped`, `confirmed`

No private keys needed, No bitcoind blockchain indexing on new servers, just address and payments.

**Donations appreciated**

`142WJW4Zzc9iV7uFdbei8Unpe8WcLhUgmE`

## Installation

Add this line to your application's Gemfile:

    gem 'cryptocoin_payable', git: 'https://github.com/Sailias/cryptocoin_payable', branch: 'master'

And then execute:

    $ bundle

    $ rails g cryptocoin_payable:install

    $ bundle exec rake db:migrate

    $ populate coin_payable.rb (see below)

    $ bundle exec rake cryptocoin_payable:process_prices (see below)

## Uninstall

    $ rails d coin_payable:install

## Run Tests

    cucumber features
    rspec

## Usage

### Configuration

config/initializers/coin_payable.rb

    CryptocoinPayable.configure do |config|
      config.currency = :usd
      config.testnet = true
      config.request_delay = 0.5

      config.configure_btc do |btc_config|
        btc_config.node_path = 'm/0/'
        btc_config.master_public_key = 'tpub...'

        # Defaults to 3 confirmations.
        # btc_config.confirmations = 3
      end

      config.configure_eth do |eth_config|
        # Will default to 4 if `config.testnet` is true, otherwise 1 but can be
        # overriden.
        #
        # 1: Frontier, Homestead, Metropolis, the Ethereum public main network
        # 4: Rinkeby, the public Geth Ethereum testnet
        # See https://ethereum.stackexchange.com/a/17101/26695
        # eth_config.chain_id = 1

        # Defaults to 12 confirmations.
        # eth_config.confirmations = 12

        eth_config.master_public_key = 'tpub...'
      end
    end

In order to use the bitcoin network and issue real addresses, CryptocoinPayable.config.testnet must be set to false:

    CryptocoinPayable.config.testnet = false

Consider adding a request delay (in seconds) to prevent API rate limit errors:

    CryptocoinPayable.config.request_delay = 0.5

#### Node Path (Bitcoin)

The derivation path for the node that will be creating your addresses.
Currently, this is only configurable for bitcoin payments (see `btc_config.node_path` above).

#### Master Public Key (Bitcoin)

A BIP32 MPK in "Extended Key" format used when configuring bitcoin payments (see `btc_config.master_public_key` above).

Public net starts with: xpub
Testnet starts with: tpub

* Obtain your BIP32 MPK from http://bip32.org/

### Adding it to your model

    class Product < ActiveRecord::Base
      has_coin_payments
    end

### Creating a payment from your application

    def create_payment(amount_in_cents)
      self.coin_payments.create!(reason: 'sale', price: amount_in_cents, coin_type: :btc)
    end

### Update payments with the current price of BTC based on your currency

CryptocoinPayable also supports local currency conversions and BTC exchange rates.

The `process_prices` rake task connects to api.bitcoinaverage.com to get the 24 hour weighted average of BTC for your specified currency.
It then updates all payments that havent received an update in the last 30 minutes with the new value owing in BTC.
This *honors* the price of a payment for 30 minutes at a time.

`rake cryptocoin_payable:process_prices`

### Processing payments

All payments are calculated against the dollar amount of the payment.  So a `bitcoin_payment` for $49.99 will have it's value calculated in BTC.
It will stay at that price for 30 minutes.  When a payment is made, a transaction is created that stores the BTC in satoshis paid and the exchange rate is was paid at.
This is very valuable for accounting later.  (capital gains of all payments received)

If a partial payment is made, the BTC value is recalculated for the remaining *dollar* amount with the latest exchange rate.
This means that if someone pays 0.01 for a 0.5 payment, that 0.01 is converted into dollars at the time of processing and the
remaining amount is calculated in dollars and the remaining amount in BTC is issued.  (If BTC bombs, that value could be greater than 0.5 now)

This prevents people from gaming the payments by paying very little BTC in hopes the price will rise.
Payments are not recalculated based on the current value of BTC, but in dollars.

To run the payment processor:

`rake cryptocoin_payable:process_payments`

### Notify your application when a payment is made

Use the `coin_payment_paid` and `coin_payment_confirmed` methods

    def Product < ActiveRecord::Base
      has_coin_payments

      def create_payment(amount_in_cents)
        self.coin_payments.create!(reason: 'sale', price: amount_in_cents, type: :btc)
      end

      # Runs when the payment is first detected on the network.
      def coin_payment_paid(payment)
        self.notify!
      end

      # Runs when enough confirmations have occurred.
      def coin_payment_confirmed(payment)
        self.ship!
      end
    end

### Delete old CurrencyConversion data

Every time the payment processor is run, several rows are inserted into the
database to record the value of the coin at a given instance in time. Over time,
your application will accumulate historical currency conversion data and you may
want to clear it out:

```
rake cryptocoin_payable:delete_currency_conversions
```

By default, it will delete any data older than 1 month. You can configure this
using an env variable:

```
DELETE_BEFORE=2017-12-15 rake cryptocoin_payable:delete_currency_conversions
```

### Comp a payment

This will bypass the payment, set the state to comped and call back to your app that the payment has been processed.

`@coin_payment.comp`

### View all the transactions in the payment

    coin_payment = @product.coin_payments.first
    coin_payment.transactions.find_each do |transaction|
      puts transaction.block_hash
      puts transaction.block_time

      puts transaction.transaction_hash

      puts transaction.estimated_value
      puts transaction.estimated_time

      puts transaction.coin_conversion

      puts transaction.confirmations
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request


## Contributors

* andersonlewin
* krtschmr
* mhluska

require 'active_record'
require 'database_cleaner'
require 'cryptocoin_payable/orm/activerecord'

describe CryptocoinPayable::PaymentProcessor do
  def build_fake_transactions_data
    transactions = []
    300.times do
      transactions << {
        transaction_hash: '5bdeaf7829148d7e0e1e7b5233512a2c5ae54ef7ccbc8e68b2f85b7e49c917a0',
        block_hash: '0000000000000000048e8ea3fdd2c3a59ddcbcf7575f82cb96ce9fd17da9f2f4',
        block_time: DateTime.iso8601('2016-09-13T15:41:00.000000000+00:00'),
        estimated_time: DateTime.iso8601('2016-09-13T15:41:00.000000000+00:00'),
        estimated_value: 499_000_000,
        confirmations: 116_077
      }
    end
    transactions
  end

  context 'when testing performance of database interaction' do
    before(:all) do
      ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'spec/dummy/db/test.sqlite3')
      DatabaseCleaner.strategy = :truncation
      GC.disable
    end

    after(:all) do
      GC.enable
    end

    before do
      DatabaseCleaner.clean
      CryptocoinPayable::CurrencyConversion.create!(coin_type: :btc, currency: 1, price: 1)
      adapter = CryptocoinPayable::Adapters.bitcoin_adapter
      allow(adapter).to receive(:fetch_transactions) { build_fake_transactions_data }
    end

    after do
      DatabaseCleaner.clean
    end

    it 'should insert 300 transactions in under 300ms' do
      payment = CryptocoinPayable::CoinPayment.create!(reason: 'test', price: 1, coin_type: :btc)
      payment.update(address: '3HR9xYD7MybbE7JLVTjwijYse48BtfEKni')

      expect { subject.update_transactions_for(payment) }.to perform_under(300).ms
    end
  end
end

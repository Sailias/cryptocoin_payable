require 'activerecord-import'

module CryptocoinPayable
  class PaymentProcessor
    def self.perform
      new.perform
    end

    def self.update_transactions_for(payment)
      new.update_transactions_for(payment)
    end

    def perform
      CoinPayment.unconfirmed.find_each do |payment|
        # Check for completed payment first, in case it's 0 and we don't need to
        # make an API call.
        update_payment_state(payment)

        next if payment.confirmed?

        begin
          update_transactions_for(payment)
        rescue StandardError => error
          STDERR.puts 'PaymentProcessor: Unknown error encountered, skipping transaction'
          STDERR.puts error
          next
        end

        # Check for payments after the response comes back.
        update_payment_state(payment)

        # If the payment has not moved out of the pending state after loading
        # new transactions, we expire it.
        update_payment_expired_state(payment) if payment.pending?
      end
    end

    def update_transactions_for(payment)
      transactions = Adapters.for(payment.coin_type).fetch_transactions(payment.address)

      if ActiveRecord::Base.connection.supports_on_duplicate_key_update?
        update_via_bulk_insert(payment, transactions)
      else
        update_via_many_insert(payment, transactions)
      end
    end

    private

    def update_via_bulk_insert(payment, transactions)
      transactions.each do |t|
        t[:coin_conversion] = payment.coin_conversion
        t[:coin_payment_id] = payment.id
      end

      payment.transaction do
        CoinPaymentTransaction.import(
          transactions,
          on_duplicate_key_update: {
            conflict_target: [:transaction_hash],
            columns: [:coin_conversion]
          }
        )
        payment.reload
        payment.update_coin_amount_due
      end
    end

    def update_via_many_insert(payment, transactions)
      transactions.each do |tx|
        transaction = payment.transactions.find_by_transaction_hash(tx[:tx_hash])
        if transaction
          transaction.update(confirmations: tx[:confirmations])
        else
          tx[:coin_conversion] = payment.coin_conversion
          payment.transactions.create!(tx)
          payment.update_coin_amount_due
        end
      end
    end

    def update_payment_state(payment)
      if payment.currency_amount_paid >= payment.price
        payment.pay
        payment.confirm if payment.transactions_confirmed?
      elsif payment.currency_amount_paid > 0
        payment.partially_pay
      end
    end

    def update_payment_expired_state(payment)
      expire_after = CryptocoinPayable.configuration.expire_payments_after
      payment.expire if expire_after.present? && (Time.now - payment.created_at) >= expire_after
    end
  end
end

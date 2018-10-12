module CryptocoinPayable
  class PaymentProcessor
    def self.perform
      new.perform
    end

    def self.update_transactions_for(payment)
      transactions = Adapters.for(payment.coin_type).fetch_transactions(payment.address)

      transactions.each do |tx|
        tx.symbolize_keys!

        transaction = payment.transactions.find_by_transaction_hash(tx[:txHash])
        if transaction
          transaction.update(confirmations: tx[:confirmations])
        else
          payment.transactions.create_from_tx_data!(tx, payment.coin_conversion)
          payment.update(
            coin_amount_due: payment.calculate_coin_amount_due,
            coin_conversion: CurrencyConversion.where(coin_type: payment.coin_type).last.price
          )
        end
      end
    end

    def perform
      CoinPayment.unconfirmed.find_each do |payment|
        # Check for completed payment first, in case it's 0 and we don't need to
        # make an API call.
        update_payment_state(payment)

        next if payment.confirmed?

        begin
          self.class.update_transactions_for(payment)
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

    protected

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

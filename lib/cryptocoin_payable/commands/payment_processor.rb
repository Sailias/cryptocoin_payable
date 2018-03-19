module CryptocoinPayable
  class PaymentProcessor
    def self.perform
      new.perform
    end

    def perform
      CoinPayment.where(state: [:pending, :partial_payment, :paid_in_full]).each do |payment|
        # Check for completed payment first, in case it's 0 and we don't need to
        # make an API call.
        update_payment_state(payment)

        next if payment.confirmed?

        begin
          transactions = Adapters.for(payment.coin_type).get_transactions_for(payment.address)
        rescue JSON::ParserError
          STDERR.puts 'Error processing response from server. Possible API issue or your Quota has been exceeded'
          next
        end

        transactions.each do |tx|
          tx.symbolize_keys!

          transaction = payment.transactions.find_by_transaction_hash(tx[:txHash])
          if transaction
            transaction.update(confirmations: tx[:confirmations])
          else
            payment.transactions.create!(
              estimated_value: tx[:estimatedTxValue],
              transaction_hash: tx[:txHash],
              block_hash: tx[:blockHash],
              block_time: tx[:blockTime],
              estimated_time: tx[:estimatedTxTime],
              coin_conversion: payment.coin_conversion,
              confirmations: tx[:confirmations]
            )

            payment.update(
              coin_amount_due: payment.calculate_coin_amount_due,
              coin_conversion: CurrencyConversion.where(coin_type: payment.coin_type).last.price
            )
          end
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
      if expire_after.present? && (Time.now - payment.created_at) >= expire_after
        payment.expire
      end
    end
  end
end

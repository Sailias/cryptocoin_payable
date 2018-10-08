module CryptocoinPayable
  class PricingProcessor
    def self.perform
      new.perform
    end

    def self.delete_currency_conversions(time_ago)
      new.delete_currency_conversions(time_ago)
    end

    def perform
      rates = CurrencyConversion.coin_types.map do |coin_pair|
        coin_type = coin_pair[0].to_sym
        [
          coin_type,
          CurrencyConversion.create!(
            # TODO: Store three previous price ranges, defaulting to 100 for now.
            currency: 100,
            price: Adapters.for(coin_type).get_rate,
            coin_type: coin_type,
          )
        ]
      end.to_h

      # Loop through all unpaid payments and update them with the new price if
      # it has been 30 mins since they have been updated.
      CoinPayment.where(state: [:pending, :partial_payment]).where("updated_at < ? OR coin_amount_due = 0", 30.minutes.ago).find_each do |payment|
        payment.update!(
          coin_amount_due: payment.calculate_coin_amount_due,
          coin_conversion: rates[payment.coin_type.to_sym].price,
        )
      end
    end

    def delete_currency_conversions(time_ago)
      # Makes sure to keep at least one record in the db since other areas of
      # the gem assume the existence of at least one record.
      last_id = CurrencyConversion.last.id
      time = time_ago || 1.month.ago
      CurrencyConversion.where('created_at < ? AND id != ?', time, last_id).delete_all
    end
  end
end

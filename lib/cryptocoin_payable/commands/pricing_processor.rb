module CryptocoinPayable
  class PricingProcessor
    def self.perform
      new.perform
    end

    def perform
      rates = CurrencyConversion.coin_types.map { |coin_name|
        [
          coin_name[0].to_sym,
          CurrencyConversion.create!(
            # TODO: Store three previous price ranges, defaulting to 100 for now.
            currency: 100,
            price: Adapters.for(coin_name[0].to_sym).get_rate,
          )
        ]
      }.to_h

      # Loop through all unpaid payments and update them with the new price if
      # it has been 30 mins since they have been updated.
      CoinPayment.where(state: [:pending, :partial_payment]).where("updated_at < ? OR coin_amount_due = 0", 30.minutes.ago).each do |payment|
        payment.update!(
          coin_amount_due: payment.calculate_coin_amount_due,
          coin_conversion: rates[payment.coin_type].price,
        )
      end
    end
  end
end

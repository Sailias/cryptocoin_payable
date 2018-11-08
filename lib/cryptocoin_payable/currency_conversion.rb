module CryptocoinPayable
  class CurrencyConversion < ActiveRecord::Base
    validates :price, presence: true

    # TODO: Duplicated in `CoinPayment`.
    enum coin_type: %i[
      bch
      btc
      eth
    ]
  end
end

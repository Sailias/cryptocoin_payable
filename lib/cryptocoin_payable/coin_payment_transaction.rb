module CryptocoinPayable
  class CoinPaymentTransaction < ActiveRecord::Base
    belongs_to :coin_payment
  end
end

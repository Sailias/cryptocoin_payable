require 'active_record'
require 'cryptocoin_payable/state_machine'
require 'cryptocoin_payable/coin_payment_transaction'
require 'cryptocoin_payable/coin_payment'
require 'cryptocoin_payable/currency_conversion'
require 'cryptocoin_payable/commands/pricing_processor'
require 'cryptocoin_payable/commands/payment_processor'

module ActiveRecord
  class Base
    def self.has_coin_payments # rubocop:disable Naming/PredicateName
      has_many :coin_payments, class_name: 'CryptocoinPayable::CoinPayment', as: 'payable'
    end
  end
end

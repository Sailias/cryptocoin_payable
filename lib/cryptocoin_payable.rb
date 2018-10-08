require 'net/http'

require 'cryptocoin_payable/config'
require 'cryptocoin_payable/errors'
require 'cryptocoin_payable/version'
require 'cryptocoin_payable/has_coin_payments'
require 'cryptocoin_payable/tasks'
require 'cryptocoin_payable/adapters'
require 'cryptocoin_payable/coin_payment_transaction'
require 'cryptocoin_payable/coin_payment'
require 'cryptocoin_payable/currency_conversion'

module CryptocoinPayable
end

ActiveSupport.on_load(:active_record) do
  include CryptocoinPayable::Model
end

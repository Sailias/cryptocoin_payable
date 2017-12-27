require 'rake'
require 'cryptocoin_payable/commands/pricing_processor'
require 'cryptocoin_payable/commands/payment_processor'

namespace :cryptocoin_payable do
  desc 'Process the prices and update the payments'
  task :process_prices => :environment do
    CryptocoinPayable::PricingProcessor.perform
  end

  desc 'Connect to HelloBlock.io and process payments'
  task :process_payments => :environment do
    CryptocoinPayable::PaymentProcessor.perform
  end
end

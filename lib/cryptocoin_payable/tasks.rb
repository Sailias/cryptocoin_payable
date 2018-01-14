require 'rake'
require 'cryptocoin_payable/commands/pricing_processor'
require 'cryptocoin_payable/commands/payment_processor'

namespace :cryptocoin_payable do
  desc 'Process the prices and update the payments'
  task :process_prices => :environment do
    CryptocoinPayable::PricingProcessor.perform
  end

  desc 'Delete old CurrencyConversion data (will delete last month by default)'
  task :delete_currency_conversions => :environment do
    CryptocoinPayable::PricingProcessor.delete_currency_conversions(ENV['DELETE_BEFORE'])
  end

  desc 'Get transactions from external API and process payments'
  task :process_payments => :environment do
    CryptocoinPayable::PaymentProcessor.perform
  end
end

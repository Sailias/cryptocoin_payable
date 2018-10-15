namespace :cryptocoin_payable do
  desc 'Process the prices and update the payments'
  task process_prices: :environment do
    CryptocoinPayable::PricingProcessor.perform
  end
end

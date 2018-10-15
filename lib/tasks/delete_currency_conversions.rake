namespace :cryptocoin_payable do
  desc 'Delete old CurrencyConversion data (will delete last month by default)'
  task delete_currency_conversions: :environment do
    CryptocoinPayable::PricingProcessor.delete_currency_conversions(ENV['DELETE_BEFORE'])
  end
end

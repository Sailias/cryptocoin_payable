namespace :cryptocoin_payable do
  desc 'Get transactions from external API and process payments'
  task process_payments: :environment do
    CryptocoinPayable::PaymentProcessor.perform
  end
end

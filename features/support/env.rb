ENV['RAILS_ENV'] ||= 'test'
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '../../../spec/dummy'

require 'cucumber/rails'
require 'cucumber/rspec/doubles'

# ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

# Remove/comment out the lines below if your app doesn't have a database.
# For some databases (like MongoDB and CouchDB) you may need to use :truncation instead.
begin
  DatabaseCleaner.strategy = :transaction
rescue NameError
  raise 'You need to add database_cleaner to your Gemfile (in the :test group) if you wish to use it.'
end

Before do
  3.times do
    CryptocoinPayable::CurrencyConversion.create!(
      coin_type: :btc,
      currency: rand(85...99),
      price: rand(10_000...15_000) * 100, # cents in fiat
    )
  end
  @currency_conversions = CryptocoinPayable::CurrencyConversion.all
end

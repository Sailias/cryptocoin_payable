require 'digest'
require 'active_record'
require 'cryptocoin_payable/orm/activerecord'

describe CryptocoinPayable::PaymentProcessor do
  def build_fake_transactions_data
    transactions = []
    300.times do |i|
      transactions << {
        transaction_hash: Digest::SHA2.new(256).hexdigest(i.to_s),
        block_hash: '0000000000000000048e8ea3fdd2c3a59ddcbcf7575f82cb96ce9fd17da9f2f4',
        block_time: DateTime.iso8601('2016-09-13T15:41:00.000000000+00:00'),
        estimated_time: DateTime.iso8601('2016-09-13T15:41:00.000000000+00:00'),
        estimated_value: 499_000_000,
        confirmations: 116_077
      }
    end
    transactions
  end

  def create_tables
    ENV['RAILS_ENV'] = 'test'
    load 'spec/dummy/db/schema.rb'
  end

  def drop_tables
    %i[
      coin_payment_transactions
      coin_payments
      currency_conversions
      widgets
    ].each do |table_name|
      ActiveRecord::Base.connection.drop_table(table_name)
    end
  end

  context 'when testing performance of database interaction' do
    before(:all) do
      ActiveRecord::Base.establish_connection(adapter: 'postgresql', database: 'cryptocoin_payable_test')
      create_tables
      GC.disable
    end

    after(:all) do
      GC.enable
      drop_tables
    end

    before do
      CryptocoinPayable::CurrencyConversion.create!(coin_type: :btc, currency: 1, price: 1)
      adapter = CryptocoinPayable::Adapters.bitcoin_adapter
      allow(adapter).to receive(:fetch_transactions) { build_fake_transactions_data }
    end

    it 'should insert 300 transactions in under 300ms', retry: 3 do
      payment = CryptocoinPayable::CoinPayment.create!(reason: 'test', price: 1, coin_type: :btc)
      payment.update(address: '3HR9xYD7MybbE7JLVTjwijYse48BtfEKni')

      expect { subject.update_transactions_for(payment) }.to perform_under(300).ms
    end
  end
end

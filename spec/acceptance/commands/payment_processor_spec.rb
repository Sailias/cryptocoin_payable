require 'active_record'
require 'cryptocoin_payable/commands/payment_processor'
require 'cryptocoin_payable/coin_payment'

describe CryptocoinPayable::PaymentProcessor do
  context 'when testing performance of database operations' do
    before(:all) { GC.disable }
    after(:all) { GC.enable }

    before do
      ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'spec/dummy/db/test.sqlite3')
    end

    it 'should update transactions 1000 times in under 50ms' do
      payment = CryptocoinPayable::CoinPayment.new(address: '3HR9xYD7MybbE7JLVTjwijYse48BtfEKni', coin_type: :btc)
      expect { 1000.times { subject.update_transactions_for(payment) } }.to perform_under(50).ms
    end
  end
end

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
        block_time: Time.iso8601('2016-09-13T15:41:00.000000000+00:00'),
        estimated_time: Time.iso8601('2016-09-13T15:41:00.000000000+00:00'),
        estimated_value: 499_000_000,
        confirmations: 116_077
      }
    end
    transactions
  end

  context 'when testing performance of database interaction' do
    before(:all) { GC.disable }
    after(:all) { GC.enable }

    before do
      adapter = CryptocoinPayable::Adapters.bitcoin_adapter
      allow(adapter).to receive(:fetch_transactions) { build_fake_transactions_data }
    end

    it 'should insert 300 transactions in under 400ms', retry: 3 do
      # TODO: Remove this once this is fixed: https://github.com/zdennis/activerecord-import/issues/559
      skip if Gem.loaded_specs['rails'].version < Gem::Version.create('4.2')

      payment = CryptocoinPayable::CoinPayment.create!(reason: 'test', price: 1, coin_type: :btc)
      payment.update(address: '3HR9xYD7MybbE7JLVTjwijYse48BtfEKni')

      expect { subject.update_transactions_for(payment) }.to perform_under(400).ms
    end
  end
end

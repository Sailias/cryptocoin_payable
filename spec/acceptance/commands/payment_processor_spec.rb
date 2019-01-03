require 'digest'
require 'active_record'
require 'cryptocoin_payable/orm/activerecord'

describe CryptocoinPayable::PaymentProcessor do
  let(:adapter) { CryptocoinPayable::Adapters.bitcoin_adapter }

  def build_fake_transactions_data(count: 10, confirmations: 10)
    transactions = []
    count.times do |i|
      transactions << {
        transaction_hash: Digest::SHA2.new(256).hexdigest(i.to_s),
        block_hash: '0000000000000000048e8ea3fdd2c3a59ddcbcf7575f82cb96ce9fd17da9f2f4',
        block_time: Time.iso8601('2016-09-13T15:41:00.000000000+00:00'),
        estimated_time: Time.iso8601('2016-09-13T15:41:00.000000000+00:00'),
        estimated_value: 499_000_000,
        confirmations: confirmations
      }
    end
    transactions
  end

  def create_payment
    payment = CryptocoinPayable::CoinPayment.create!(reason: 'test', price: 1, coin_type: :btc)
    payment.update(address: '3HR9xYD7MybbE7JLVTjwijYse48BtfEKni')
    payment
  end

  context 'when using bulk insert' do
    before do
      # TODO: Remove this once this is fixed: https://github.com/zdennis/activerecord-import/issues/559
      skip if Gem.loaded_specs['rails'].version < Gem::Version.create('4.2')
    end

    context 'when testing performance' do
      before { GC.disable }
      after { GC.enable }

      before do
        allow(adapter).to receive(:fetch_transactions) { build_fake_transactions_data(count: 300) }
      end

      it 'should insert 300 transactions in under 400ms', retry: 3 do
        payment = create_payment
        expect { subject.update_transactions_for(payment) }.to perform_under(400).ms
      end
    end

    it 'should update the confirmation count' do
      payment = create_payment

      expect(payment.transactions.size).to eq(0)

      allow(adapter).to receive(:fetch_transactions) { build_fake_transactions_data(confirmations: 5) }
      subject.update_transactions_for(payment)

      expect(payment.transactions.size).to eq(10)

      allow(adapter).to receive(:fetch_transactions) { build_fake_transactions_data(confirmations: 10) }
      subject.update_transactions_for(payment)

      expect(payment.transactions.size).to eq(10)
      expect(payment.transactions.last.confirmations).to eq(10)
    end
  end
end

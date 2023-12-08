require 'active_record'
require 'cryptocoin_payable'
require 'cryptocoin_payable/orm/activerecord'

describe CryptocoinPayable::CoinPayment do
  context 'when creating a Bitcoin Cash payment' do
    subject { CryptocoinPayable::CoinPayment.new(coin_type: :bch, reason: 'test', price: 1) }

    it 'can save a payment' do
      expect { subject.save! }.not_to raise_error
    end

    it 'can update the coin amount due' do
      subject.update_coin_amount_due
      expect(subject.coin_amount_due).to eq(100_000_000)
      expect(subject.coin_amount_due_main).to eq(1)
      expect(subject.coin_conversion).to eq(1)
    end
  end

  context 'when creating a Bitcoin payment' do
    subject { CryptocoinPayable::CoinPayment.new(coin_type: :btc, reason: 'test', price: 590) }

    it 'can save a payment' do
      expect { subject.save! }.not_to raise_error
    end

    it 'can update the coin amount due' do
      subject.update_coin_amount_due
      expect(subject.coin_amount_due).to eq(59_000_000_000)
      expect(subject.coin_amount_due_main).to eq(590)
      expect(subject.coin_conversion).to eq(1)
    end
  end
end

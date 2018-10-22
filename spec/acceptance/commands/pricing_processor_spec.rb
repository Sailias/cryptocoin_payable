require 'digest'
require 'active_record'
require 'cryptocoin_payable/orm/activerecord'
require 'timecop'

describe CryptocoinPayable::PricingProcessor, vcr: true do
  context 'when updating stale payments' do
    before do
      # Ensure we have a stale payment.
      Timecop.freeze(3.days.from_now)

      CryptocoinPayable::CurrencyConversion.create!(
        coin_type: :btc,
        currency: 1,
        price: 1
      )

      CryptocoinPayable::CoinPayment.create!(
        state: :pending,
        coin_type: :btc,
        price: 1,
        reason: 'test'
      )
    end

    after do
      Timecop.return
    end

    it 'can update' do
      subject.perform
    end
  end
end

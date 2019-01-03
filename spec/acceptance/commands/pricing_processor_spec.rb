require 'timecop'

describe CryptocoinPayable::PricingProcessor, vcr: true do
  context 'when updating stale payments' do
    before do
      # Ensure we have a stale payment.
      Timecop.freeze(3.days.from_now)

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

    it 'can update without errors' do
      subject.perform
    end
  end
end

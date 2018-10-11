When(/^the payment_processor is run$/) do
  CryptocoinPayable::PaymentProcessor.perform
end

When(/^the pricing processor is run$/) do
  CryptocoinPayable::PricingProcessor.perform
end

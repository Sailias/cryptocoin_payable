require 'money-tree'
require 'state_machine'

module CryptocoinPayable
  class CoinPayment < ActiveRecord::Base
    belongs_to :payable, polymorphic: true
    has_many :transactions, class_name: 'CryptocoinPayable::CoinPaymentTransaction'

    validates :reason, presence: true
    validates :price, presence: true
    validates :coin_type, presence: true

    before_create :populate_currency_and_amount_due
    after_create :populate_address

    scope :unconfirmed, -> { where(state: [:pending, :partial_payment, :paid_in_full]) }
    scope :unpaid, -> { where(state: [:pending, :partial_payment]) }
    scope :stale, -> { where('updated_at < ? OR coin_amount_due = 0', 30.minutes.ago) }

    # TODO: Duplicated in `CurrencyConversion`.
    enum coin_type: %i[
      btc
      eth
    ]

    state_machine :state do
      state :pending
      state :partial_payment
      state :paid_in_full
      state :confirmed
      state :comped

      event :paid do
        transition [:pending, :partial_payment] => :paid_in_full
      end

      after_transition :on => :paid, :do => :notify_payable

      event :partially_paid do
        transition :pending => :partial_payment
      end

      event :comp do
        transition [:pending, :partial_payment] => :comped
      end

      after_transition :on => :comp, :do => :notify_payable

      event :confirmed do
        transition :paid_in_full => :confirmed
      end

      after_transition :on => :confirmed, :do => :notify_payable_confirmed
    end

    # @returns cents in fiat currency.
    def currency_amount_paid
      adapter = Adapters.for(coin_type)
      cents = transactions.inject(0) do |sum, tx|
        sum + (adapter.convert_subunit_to_main(tx.estimated_value) * tx.coin_conversion)
      end

      # Round to 0 decimal places so there aren't any partial cents.
      cents.round(0)
    end

    def currency_amount_due
      self.price - currency_amount_paid
    end

    def calculate_coin_amount_due
      rate = CurrencyConversion.where(coin_type: coin_type).last.price
      Adapters.for(coin_type).convert_main_to_subunit(currency_amount_due / rate.to_f).ceil
    end

    def transactions_confirmed?
      transactions.all? { |t|
        t.confirmations >= CryptocoinPayable.configuration.send(coin_type).confirmations
      }
    end

    private

    def populate_currency_and_amount_due
      self.currency ||= CryptocoinPayable.configuration.currency
      self.coin_amount_due = calculate_coin_amount_due
      self.coin_conversion = CurrencyConversion.where(coin_type: coin_type).last.price
    end

    def populate_address
      self.update(address: Adapters.for(coin_type).create_address(self.id))
    end

    def notify_payable
      if self.payable.respond_to?(:coin_payment_paid)
        self.payable.coin_payment_paid(self)
      end
    end

    def notify_payable_confirmed
      if self.payable.respond_to?(:coin_payment_confirmed)
        self.payable.coin_payment_confirmed(self)
      end
    end
  end
end

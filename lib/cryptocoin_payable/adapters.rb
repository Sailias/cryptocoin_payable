module CryptocoinPayable
  module Adapters
    def self.for(coin_type)
      case coin_type.to_sym
      when :bch
        bitcoin_cash_adapter
      when :btc
        bitcoin_adapter
      when :eth
        ethereum_adapter
      else
        raise "Invalid coin type #{coin_type}"
      end
    end

    def self.bitcoin_cash_adapter
      @bitcoin_cash_adapter ||= BitcoinCash.new
    end

    def self.bitcoin_adapter
      @bitcoin_adapter ||= Bitcoin.new
    end

    def self.ethereum_adapter
      @ethereum_adapter ||= Ethereum.new
    end
  end
end

require 'cryptocoin_payable/adapters/base'
require 'cryptocoin_payable/adapters/bitcoin'
require 'cryptocoin_payable/adapters/bitcoin_cash'
require 'cryptocoin_payable/adapters/ethereum'

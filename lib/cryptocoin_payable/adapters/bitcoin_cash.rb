require 'cash_addr'

module CryptocoinPayable
  module Adapters
    class BitcoinCash < Bitcoin
      def self.coin_symbol
        'BCH'
      end

      def fetch_transactions(address)
        raise NetworkNotSupported if CryptocoinPayable.configuration.testnet

        url = "https://#{prefix}blockexplorer.com/api/txs/?address=#{legacy_address(address)}"
        parse_block_exporer_transactions(get_request(url).body, address)
      end

      def create_address(id)
        CashAddr::Converter.to_cash_address(super)
      end

      private

      def legacy_address(address)
        CashAddr::Converter.to_legacy_address(address)
      rescue CashAddr::InvalidAddress
        raise ApiError
      end

      def prefix
        CryptocoinPayable.configuration.testnet ? 'bchtest.' : 'bitcoincash.'
      end
    end
  end
end

require 'cash_addr'

module CryptocoinPayable
  module Adapters
    class BitcoinCash < Base
      # Satoshi in Bitcoin
      def self.subunit_in_main
        100_000_000
      end

      def self.coin_symbol
        'BCH'
      end

      def fetch_transactions(address)
        raise NetworkNotSupported if CryptocoinPayable.configuration.testnet

        legacy_address = CashAddr::Converter.to_legacy_address(address)
        url = "https://#{prefix}blockexplorer.com/api/txs/?address=#{legacy_address}"
        parse_block_exporer_transactions(get_request(url).body, address)
      rescue CashAddr::InvalidAddress
        raise ApiError
      end

      def create_address(id)
        CashAddr::Converter.to_cash_address(super.to_address(network: network))
      end

      private

      def prefix
        CryptocoinPayable.configuration.testnet ? 'bchtest.' : 'bitcoincash.'
      end

      def network
        CryptocoinPayable.configuration.testnet ? :bitcoin_testnet : :bitcoin
      end

      def parse_time(timestamp)
        DateTime.strptime(timestamp.to_s, '%s')
      end

      def parse_total_tx_value(output_transactions, address)
        output_transactions
          .select { |out| out['scriptPubKey']['addresses'].try('include?', address) }
          .sum { |out| (out['value'].to_f * self.class.subunit_in_main).to_i }
      end

      def parse_block_exporer_transactions(response, address)
        json = JSON.parse(response)
        json['txs'].map { |tx| convert_transactions(tx, address) }
      rescue JSON::ParserError
        raise ApiError, response
      end

      def convert_transactions(transaction, address)
        {
          tx_hash: transaction['txid'],
          block_hash: transaction['blockhash'],
          block_time: transaction['blocktime'].nil? ? nil : parse_time(transaction['blocktime']),
          estimated_tx_time: parse_time(transaction['time']),
          estimated_tx_value: parse_total_tx_value(transaction['vout'], address),
          confirmations: transaction['confirmations']
        }
      end
    end
  end
end

module CryptocoinPayable
  module Adapters
    class Bitcoin < Base
      # Satoshi in Bitcoin
      def self.subunit_in_main
        100_000_000
      end

      def self.coin_symbol
        'BTC'
      end

      def fetch_transactions(address)
        fetch_block_explorer_transactions(address)
      rescue StandardError
        fetch_block_cypher_transactions(address)
      end

      def create_address(id)
        super.to_address(network: network)
      end

      private

      def prefix
        CryptocoinPayable.configuration.testnet ? 'testnet.' : ''
      end

      def network
        CryptocoinPayable.configuration.testnet ? :bitcoin_testnet : :bitcoin
      end

      def parse_total_tx_value_block_explorer(output_transactions, address)
        output_transactions
          .reject { |out| out['scriptPubKey']['addresses'].nil? }
          .select { |out| out['scriptPubKey']['addresses'].include?(address) }
          .map { |out| (out['value'].to_f * self.class.subunit_in_main).to_i }
          .inject(:+)
      end

      def fetch_block_explorer_transactions(address)
        url = "https://#{prefix}blockexplorer.com/api/txs/?address=#{address}"
        parse_block_explorer_transactions(get_request(url).body, address)
      end

      def parse_block_explorer_transactions(response, address)
        json = JSON.parse(response)
        json['txs'].map { |tx| convert_block_explorer_transactions(tx, address) }
      rescue JSON::ParserError
        raise ApiError, response
      end

      def convert_block_explorer_transactions(transaction, address)
        {
          tx_hash: transaction['txid'],
          block_hash: transaction['blockhash'],
          block_time: parse_timestamp(transaction['blocktime']),
          estimated_tx_time: parse_timestamp(transaction['time']),
          estimated_tx_value: parse_total_tx_value_block_explorer(transaction['vout'], address),
          confirmations: transaction['confirmations']
        }
      end

      def parse_total_tx_value_block_cypher(output_transactions, address)
        output_transactions
          .sum { |out| out['addresses'].join.eql?(address) ? out['value'] : 0 }
      end

      def fetch_block_cypher_transactions(address)
        url = "https://api.blockcypher.com/v1/btc/main/addrs/#{address}/full"
        parse_block_cypher_transactions(get_request(url).body, address)
      end

      def parse_block_cypher_transactions(response, address)
        json = JSON.parse(response)
        raise ApiError, json['error'] if json['error']

        json['txs'].map { |tx| convert_block_cypher_transactions(tx, address) }
      rescue JSON::ParserError
        raise ApiError, response
      end

      def convert_block_cypher_transactions(transaction, address)
        {
          tx_hash: transaction['hash'],
          block_hash: transaction['block_hash'],
          block_time: parse_time(transaction['confirmed']),
          estimated_tx_time: parse_time(transaction['received']),
          estimated_tx_value: parse_total_tx_value_block_cypher(transaction['outputs'], address),
          confirmations: transaction['confirmations'].to_i
        }
      end
    end
  end
end

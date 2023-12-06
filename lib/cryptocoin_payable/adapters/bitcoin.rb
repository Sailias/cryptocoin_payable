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
        fetch_blockstream_transactions(address)
      rescue StandardError => e
        logger.info "Blockstream API failed, falling back to BlockCypher #{e.message}"
        fetch_block_cypher_transactions(address)
      end

      def create_address(id)
        super.to_address(network:)
      end

      private

      def prefix_blockstream
        CryptocoinPayable.configuration.testnet ? 'testnet/' : ''
      end
      def prefix_block_cypher
        CryptocoinPayable.configuration.testnet ? 'test3' : ''
      end

      def network
        CryptocoinPayable.configuration.testnet ? :bitcoin_testnet : :bitcoin
      end

      def parse_total_tx_value_blockstream(output_transactions, address)
        output_transactions
          .select { |out| out['scriptpubkey_address'] == address }
          .map { |out| out['value'] }
          .inject(:+) || 0
      end

      def fetch_blockstream_transactions(address)
        url = "https://blockstream.info/#{prefix_blockstream}api/address/#{address}/txs"
        parse_blockstream_transactions(get_request(url).body, address)
      end

      def parse_blockstream_transactions(response, address)
        json = JSON.parse(response)
        json.map { |tx| convert_blockstream_transactions(tx, address) }
      rescue JSON::ParserError
        raise ApiError, response
      end

      def convert_blockstream_transactions(transaction, address)
        {
          transaction_hash: transaction['txid'],
          block_hash: transaction['status']['block_hash'],
          block_time: parse_timestamp(transaction['status']['block_time']),
          estimated_time: parse_timestamp(transaction['status']['block_time']),
          estimated_value: parse_total_tx_value_blockstream(transaction['vout'], address),
          confirmations: 1 #blocktstream only returns true or false for confirmed
        }
      end

      def parse_total_tx_value_block_cypher(output_transactions, address)
        output_transactions
          .map { |out| out['addresses'].join.eql?(address) ? out['value'] : 0 }
          .inject(:+) || 0
      end

      def fetch_block_cypher_transactions(address)
        url = "https://api.blockcypher.com/v1/btc/#{prefix_block_cypher}/addrs/#{address}/full"
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
          transaction_hash: transaction['hash'],
          block_hash: transaction['block_hash'],
          block_time: parse_time(transaction['confirmed']),
          estimated_time: parse_time(transaction['received']),
          estimated_value: parse_total_tx_value_block_cypher(transaction['outputs'], address),
          confirmations: transaction['confirmations'].to_i
        }
      end
    end
  end
end

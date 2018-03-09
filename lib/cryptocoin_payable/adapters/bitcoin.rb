require 'blockcypher'

module CryptocoinPayable
  module Adapters
    class Bitcoin < Coin
      SATOSHI_IN_BITCOIN = 100_000_000

      def self.subunit_in_main
        SATOSHI_IN_BITCOIN
      end

      def self.coin_symbol
        'BTC'
      end

      def self.get_transactions_for(address)
        response = adapter.address_full_txs(address)

        if response['error'] && response['error'].include?('API calls limits have been reached')
          raise ApiLimitReached
        end

        response['txs'].map { |tx| convert_transactions(tx, address) }
      end

      def self.create_address(id)
        key = CryptocoinPayable.configuration.btc.master_public_key

        raise 'master_public_key is required' unless key

        master = MoneyTree::Node.from_bip32(key)
        node = master.node_for_path(CryptocoinPayable.configuration.btc.node_path + id.to_s)
        node.to_address(network: CryptocoinPayable.configuration.btc.network)
      end

      private_class_method def self.adapter
        @adapter ||= BlockCypher::Api.new(
          api_token: CryptocoinPayable.configuration.btc.blockcypher_token,
          network: CryptocoinPayable.configuration.testnet ? BlockCypher::TEST_NET_3 : BlockCypher::MAIN_NET
        )
      end

      private_class_method def self.convert_transactions(transaction, address)
        {
          txHash: transaction['hash'],
          blockHash: transaction['block_hash'],
          blockTime: transaction['confirmed'].nil? ? nil : DateTime.iso8601(transaction['confirmed']),
          estimatedTxTime: DateTime.iso8601(transaction['received']),
          estimatedTxValue: transaction['outputs'].sum { |out| out['addresses'].join.eql?(address) ? out['value'] : 0 },
          confirmations: transaction['confirmations'].to_i
        }
      end
    end
  end
end

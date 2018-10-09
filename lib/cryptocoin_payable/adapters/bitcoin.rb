module CryptocoinPayable
  module Adapters
    class Bitcoin < Base
      SATOSHI_IN_BITCOIN = 100_000_000

      def self.subunit_in_main
        SATOSHI_IN_BITCOIN
      end

      def self.coin_symbol
        'BTC'
      end

      def self.get_transactions_for(address)
        prefix = CryptocoinPayable.configuration.testnet ? 'testnet.' : ''
        url = "https://#{prefix}blockexplorer.com/api/txs/?address=#{address}"
        parse_block_exporer_transactions(get_request(url).body, address)
      end

      def self.create_address(id)
        key = CryptocoinPayable.configuration.btc.master_public_key

        raise 'master_public_key is required' unless key

        master = MoneyTree::Node.from_bip32(key)
        node = master.node_for_path(CryptocoinPayable.configuration.btc.node_path + id.to_s)
        node.to_address(network: CryptocoinPayable.configuration.btc.network)
      end

      private_class_method def self.parse_block_exporer_transactions(response, address)
        json = JSON.parse(response)
        json['txs'].map { |tx| convert_transactions(tx, address) }
      rescue JSON::ParserError
        raise ApiError.new(response)
      end

      private_class_method def self.convert_transactions(transaction, address)
        {
          tx_hash: transaction['txid'],
          block_hash: transaction['blockhash'],
          block_time: transaction['blocktime'].nil? ? nil : DateTime.strptime(transaction['blocktime'].to_s, '%s'),
          estimated_tx_time: DateTime.strptime(transaction['time'].to_s, '%s'),
          estimated_tx_value: transaction['vout']
            .select { |out| out['scriptPubKey']['addresses'].try('include?', address) }
            .sum { |out| (out['value'].to_f * SATOSHI_IN_BITCOIN).to_i },
          confirmations: transaction['confirmations']
        }
      end
    end
  end
end

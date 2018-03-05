require 'eth'

module CryptocoinPayable
  module Adapters
    class Ethereum < Coin
      WEI_IN_ETHER = 1_000_000_000_000_000_000

      def self.subunit_in_main
        WEI_IN_ETHER
      end

      def self.coin_symbol
        'ETH'
      end

      def self.get_transactions_for(address)
        url = "#{adapter_domain}/api?module=account&action=txlist&address=#{address}&tag=latest"
        url += '?apiKey=' + CryptocoinPayable.configuration.eth.adapter_api_key if CryptocoinPayable.configuration.eth.adapter_api_key

        response = get_request(url)
        json = JSON.parse(response.body)
        json['result'].map {|tx| convert_transactions(tx, address)}
      end

      def self.create_address(id)
        key = CryptocoinPayable.configuration.eth.master_public_key

        raise 'master_public_key is required' unless key

        master = MoneyTree::Node.from_bip32(key)
        node = master.node_for_path(id.to_s)
        Eth::Utils.public_key_to_address(node.public_key.uncompressed.to_hex)
      end

      private_class_method def self.adapter_domain
        @adapter_domain ||= if CryptocoinPayable.configuration.testnet
          'https://rinkeby.etherscan.io'
        else
          'https://api.etherscan.io'
        end
      end

      # Example response:
      # {
      #   status: "1",
      #   message: "OK",
      #   result: [
      #     {
      #       blockNumber: "4790248",
      #       timeStamp: "1514144760",
      #       hash: "0x52345400e42a15ba883fb0e314d050a7e7e376a30fc59dfcd7b841007d5d710c",
      #       nonce: "215964",
      #       blockHash: "0xe6ed0d98586cae04be57e515ca7773c020b441de60a467cd2773877a8996916f",
      #       transactionIndex: "4",
      #       from: "0xd24400ae8bfebb18ca49be86258a3c749cf46853",
      #       to: "0x911f9d574d1ca099cae5ab606aa9207fe238579f",
      #       value: "10000000000000000",
      #       gas: "90000",
      #       gasPrice: "28000000000",
      #       isError: "0",
      #       txreceipt_status: "1",
      #       input: "0x",
      #       contractAddress: "",
      #       cumulativeGasUsed: "156270",
      #       gasUsed: "21000",
      #       confirmations: "154"
      #     }
      #   ]
      # }
      private_class_method def self.convert_transactions(transaction, address)
        {
          txHash: transaction['hash'],
          blockHash: transaction['blockHash'],
          blockTime: nil, # Not supported
          estimatedTxTime: Time.at(transaction['timeStamp'].to_i).iso8601,
          estimatedTxValue: transaction['value'].to_i, # Units here are "Wei", comparable to "Satoshi"
          confirmations: transaction['confirmations'].to_i
        }
      end
    end
  end
end

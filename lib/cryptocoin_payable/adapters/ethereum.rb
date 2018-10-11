require 'eth'

module CryptocoinPayable
  module Adapters
    class Ethereum < Base
      WEI_IN_ETHER = 1_000_000_000_000_000_000

      def subunit_in_main
        WEI_IN_ETHER
      end

      def coin_symbol
        'ETH'
      end

      def get_transactions_for(address)
        api_adapter_key = CryptocoinPayable.configuration.eth.try(:adapter_api_key)
        url = "#{adapter_domain}/api?module=account&action=txlist&address=#{address}&tag=latest"
        url += '?apiKey=' + api_adapter_key if api_adapter_key

        response = get_request(url)
        json = JSON.parse(response.body)

        raise ApiError, json['message'] if json['status'] == '0' && json['message'] == 'NOTOK'

        json['result'].map { |tx| convert_transactions(tx, address) }
      end

      def create_address(id)
        key = CryptocoinPayable.configuration.eth.master_public_key

        raise 'master_public_key is required' unless key

        master = MoneyTree::Node.from_bip32(key)
        node = master.node_for_path(id.to_s)
        Eth::Utils.public_key_to_address(node.public_key.uncompressed.to_hex)
      end

      private

      def adapter_domain
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
      #       block_hash: "0xe6ed0d98586cae04be57e515ca7773c020b441de60a467cd2773877a8996916f",
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
      def convert_transactions(transaction, _address)
        {
          tx_hash: transaction['hash'],
          block_hash: transaction['block_hash'],
          block_time: nil, # Not supported
          estimated_tx_time: Time.at(transaction['timeStamp'].to_i).iso8601,
          estimated_tx_value: transaction['value'].to_i, # Units here are "Wei", comparable to "Satoshi"
          confirmations: transaction['confirmations'].to_i
        }
      end
    end
  end
end

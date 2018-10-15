require 'eth'

module CryptocoinPayable
  module Adapters
    class Ethereum < Base
      # Wei in Ether
      def self.subunit_in_main
        1_000_000_000_000_000_000
      end

      def self.coin_symbol
        'ETH'
      end

      def fetch_transactions(address)
        api_adapter_key = coin_config.try(:adapter_api_key)
        url = "https://#{subdomain}.etherscan.io/api?module=account&action=txlist&address=#{address}&tag=latest"
        url += '?apiKey=' + api_adapter_key if api_adapter_key

        response = get_request(url)
        json = JSON.parse(response.body)

        raise ApiError, json['message'] if json['status'] == '0' && json['message'] == 'NOTOK'

        json['result'].map { |tx| convert_transactions(tx, address) }
      end

      def create_address(id)
        Eth::Utils.public_key_to_address(super.public_key.uncompressed.to_hex)
      end

      private

      def subdomain
        @subdomain ||= CryptocoinPayable.configuration.testnet ? 'rinkeby' : 'api'
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
          transaction_hash: transaction['hash'],
          block_hash: transaction['block_hash'],
          block_time: nil, # Not supported
          estimated_time: parse_timestamp(transaction['timeStamp']),
          estimated_value: transaction['value'].to_i, # Units here are 'Wei'
          confirmations: transaction['confirmations'].to_i
        }
      end
    end
  end
end

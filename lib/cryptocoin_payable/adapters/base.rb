module CryptocoinPayable
  module Adapters
    class Base
      # Implement these in a subclass:

      # Returns the amount of cents in the main unit. E.g. 10^18 Wei in Ether.
      # def self.subunit_in_main
      #   1_000_000_000_000_000_000
      # end

      # Returns the currency symbol (used for querying for ticker data).
      # def self.coin_symbol
      #   'ETH'
      # end

      # Queries an API like etherscan.io and returns a list of transactions
      # which conform to the following shape:
      # {
      #   transaction_hash: string,
      #   block_hash: string,
      #   block_time: nil | string,
      #   estimated_time: nil | string,
      #   estimated_value: integer,
      #   confirmations: integer,
      # }
      # `block_time` and `estimated_time` are optional strings conforming to
      # date format ISO 8601.
      #
      # Can optionally raise ApiLimitedReached if needed.
      #
      # def self.fetch_transactions(address)
      # end

      # Uses a predefined seed to generate HD addresses based on an index/id
      # passed into the method.
      # def self.create_address(id)
      # end

      def convert_subunit_to_main(subunit)
        subunit / self.class.subunit_in_main.to_f
      end

      def convert_main_to_subunit(main)
        (main * self.class.subunit_in_main).to_i
      end

      def fetch_rate
        currency = CryptocoinPayable.configuration.currency.to_s.upcase
        symbol = self.class.coin_symbol
        amount =
          begin
            response = get_request("https://api.coinbase.com/v2/prices/#{symbol}-#{currency}/spot")
            JSON.parse(response.body)['data']['amount'].to_f
          rescue StandardError
            response = get_request("https://api.gemini.com/v1/pubticker/#{symbol}#{currency}")
            JSON.parse(response.body)['last'].to_f
          end

        (amount * 100).to_i
      end

      def create_address(id)
        raise MissingMasterPublicKey, 'master_public_key is required' unless coin_config.master_public_key

        master = MoneyTree::Node.from_bip32(coin_config.master_public_key)
        master.node_for_path(coin_config.node_path + id.to_s)
      end

      protected

      def coin_config
        @coin_config ||= CryptocoinPayable.configuration.send(self.class.coin_symbol.downcase)
      end

      def adapter_api_key
        @adapter_api_key ||= coin_config && coin_config.adapter_api_key
      end

      def parse_timestamp(timestamp)
        timestamp.nil? ? nil : DateTime.strptime(timestamp.to_s, '%s')
      end

      def parse_time(time)
        time.nil? ? nil : DateTime.iso8601(time)
      end

      private

      def get_request(url)
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        request = Net::HTTP::Get.new(uri.request_uri)
        result = http.request(request)

        request_delay = CryptocoinPayable.configuration.request_delay
        sleep request_delay if request_delay

        result
      end
    end
  end
end

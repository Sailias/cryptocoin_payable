module CryptocoinPayable
  module Adapters
    protected

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
      #   txHash: string,
      #   blockHash: string,
      #   blockTime: nil | string,
      #   estimatedTxTime: nil | string,
      #   estimatedTxValue: integer,
      #   confirmations: integer,
      # }
      # `blockTime` and `estimatedTxTime` are optional strings conforming to
      # date format ISO 8601.
      #
      # Can optionally raise ApiLimitedReached if needed.
      #
      # def self.get_transactions_for(address)
      # end

      # Uses a predefined seed to generate HD addresses based on an index/id
      # passed into the method.
      # def self.create_address(id)
      # end

      protected

      def self.convert_subunit_to_main(subunit)
        subunit / subunit_in_main.to_f
      end

      def self.convert_main_to_subunit(main)
        (main * subunit_in_main).to_i
      end

      def self.get_rate
        amount = begin
          response = get_request("https://api.coinbase.com/v2/prices/#{coin_symbol}-#{CryptocoinPayable.configuration.currency.to_s.upcase}/spot")
          JSON.parse(response.body)['data']['amount'].to_f
        rescue
          response = get_request("https://api.gemini.com/v1/pubticker/#{coin_symbol}#{CryptocoinPayable.configuration.currency.to_s.upcase}")
          JSON.parse(response.body)['last'].to_f
        end
        (amount * 100).to_i
      end

      private

      def self.get_request(url)
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == 'https'
        request = Net::HTTP::Get.new(uri.request_uri)
        http.request(request)
      end
    end
  end
end

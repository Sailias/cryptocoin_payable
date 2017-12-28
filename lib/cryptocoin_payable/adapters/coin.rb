module CryptocoinPayable
  module Adapters
    protected

    class Coin
      # Implement these in a subclass:

      # def self.subunit_in_main
      #   1_000_000_000_000_000_000
      # end

      # def self.coin_symbol
      #   'ETH'
      # end

      # def self.get_transactions_for(address)
      # end

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
        rescue EOFError
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

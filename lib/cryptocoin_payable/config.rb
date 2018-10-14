module CryptocoinPayable
  class << self
    attr_accessor :configuration
  end

  def self.configure
    @configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :testnet, :expire_payments_after, :request_delay, :btc, :bch, :eth
    attr_writer :currency

    def currency
      @currency ||= :usd
    end

    def configure_btc
      @btc ||= BtcConfiguration.new
      yield(@btc)
    end

    def configure_bch
      @bch ||= BchConfiguration.new
      yield(@bch)
    end

    def configure_eth
      @eth ||= EthConfiguration.new
      yield(@eth)

      Eth.configure do |config|
        config.chain_id = CryptocoinPayable.configuration.testnet ? 4 : 1
      end
    end

    class CoinConfiguration
      attr_accessor :master_public_key, :confirmations, :adapter_api_key
      attr_writer :node_path

      def node_path
        @node_path ||= ''
      end
    end

    class BtcConfiguration < CoinConfiguration
      def confirmations
        @confirmations ||= 3
      end
    end

    class BchConfiguration < CoinConfiguration
      def confirmations
        @confirmations ||= 3
      end
    end

    class EthConfiguration < CoinConfiguration
      def confirmations
        @confirmations ||= 12
      end
    end
  end
end

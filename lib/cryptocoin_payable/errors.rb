module CryptocoinPayable
  class ApiError < StandardError; end
  class ApiLimitReached < ApiError; end
  class ConfigError < StandardError; end
  class MissingMasterPublicKey < ConfigError; end
  class NetworkNotSupported < ConfigError; end
end

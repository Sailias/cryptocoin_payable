module CryptocoinPayable
  class ApiError < StandardError; end
  class ApiLimitReached < ApiError; end
end

module CryptocoinPayable
	module QRCodes
		def self.for(coin_type)
			case coin_type.to_sym
			when :bch
				raise 'Bitcoin Cash not supported yet'
			when :btc
				Bitcoin
			when :eth
				raise 'Ethereum not supported yet'
			else
				raise "Invalid coin type #{coin_type}"
			end
		end
	end
end

require 'cryptocoin_payable/qr_codes/base'
require 'cryptocoin_payable/qr_codes/bitcoin'
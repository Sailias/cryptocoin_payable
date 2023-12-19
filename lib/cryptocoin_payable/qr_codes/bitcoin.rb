module CryptocoinPayable
	module QRCodes
		class Bitcoin < Base

			def self.name
				'bitcoin'
			end

			# Bitcoin URI Scheme (BIP21)
			# https://github.com/bitcoin/bips/blob/master/bip-0021.mediawiki
			def uri_scheme
				uri = "bitcoin:#{address}?amount=#{amount}"
				uri += "&message=#{reason}" if reason.present?
				uri
			end
		end
	end
end
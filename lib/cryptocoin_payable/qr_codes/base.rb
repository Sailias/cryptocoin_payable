module CryptocoinPayable
	module QRCodes
		class Base
			attr_reader :amount, :address, :reason, :options
			def initialize(amount:, address:, reason:, options: {})
				@amount = amount
				@address = address
				@reason = reason
				@options = options
			end

			def self.logo_path
				File.expand_path("#{name}.svg", File.join(__dir__,'..', '..', 'assets'))
			end

			def self.name
				raise NotImplementedError
			end

			def generate
				result_image = ImageProcessing::Vips.source(qrcode_temp.path)
				                                    .composite(logo_image, gravity: 'south-west', offset: [center_x, center_y])
				                                    .call
				# This was use to generate file for testing
				# result_path = File.join(File.dirname(__FILE__), 'qrcode_with_logo.jpg')
				# result_image.write_to_file(result_path)
				# puts "QR code with logo saved to #{result_path}"
				# qrcode_temp.close!
			end

			def logo_image
				ImageProcessing::Vips.source(self.class.logo_path).resize_to_fit(300, 300).call(save: false)
			end
			def center_x
				(qrcode_image.width - logo_image.width) / 2
			end

			def center_y
				(qrcode_image.height - logo_image.height) / 2
			end
			def qrcode_image
				@qrcode_image ||= generate_qrcode_image
			end

			def qrcode_temp
				@qrcode_temp ||= generate_qrcode_temp
			end

			def uri_scheme
				raise NotImplementedError
			end

			private

			def generate_qrcode_image
				qrcode = RQRCode::QRCode.new(uri_scheme)
				qrcode.as_png(options)
			end

			def generate_qrcode_temp
				tmp = Tempfile.new(['qrcode_image', '.png'])
				qrcode_image.save(tmp.path)
				tmp
			end

		end
	end
end
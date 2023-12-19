module CryptocoinPayable
end

if defined?(Rails)
  module CryptocoinPayable
    class Railtie < Rails::Railtie
      initializer 'cryptocoin_payable.active_record' do
        ActiveSupport.on_load(:active_record) do
            require 'cryptocoin_payable/orm/activerecord'
        end
      end

      initializer 'cryptocoin_payable.active_storage', after: 'active_storage.reflection' do
        require 'cryptocoin_payable/coin_payment'
        config.after_initialize do
          if CryptocoinPayable.configuration.qrcode?
            require 'rqrcode'
            require 'image_processing/vips'
            require 'cryptocoin_payable/qr_codes'
            CryptocoinPayable::CoinPayment.has_one_attached(:qrcode)
          end
        end
      end

      rake_tasks do
        path = File.expand_path(__dir__)
        Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
      end
    end
  end
end

require 'cryptocoin_payable/config'
require 'cryptocoin_payable/errors'
require 'cryptocoin_payable/version'
require 'cryptocoin_payable/adapters'

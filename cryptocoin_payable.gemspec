lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cryptocoin_payable/version'

# rubocop:disable Metrics/BlockLength
Gem::Specification.new do |spec|
  spec.name          = 'cryptocoin_payable'
  spec.version       = CryptocoinPayable::VERSION
  spec.authors       = ['Jonathan Salis', 'Maros Hluska']
  spec.email         = ['jsalis@bitcoinsultants.ca', 'mhluska@gmail.com']
  spec.description   = 'Cryptocurrency payment processor'
  spec.summary       = 'Cryptocurrency payment processor'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.required_rubygems_version = '>= 1.3.6'
  spec.required_ruby_version = '>= 2.2.0'

  spec.add_development_dependency 'bundler', '~> 2.4'
  spec.add_development_dependency 'cucumber'
  spec.add_development_dependency 'cucumber-rails'
  spec.add_development_dependency 'database_cleaner', '~> 1.7'
  spec.add_development_dependency 'pg', '~> 1.5.4'
  spec.add_development_dependency 'rails', '>= 4.0.0'
  spec.add_development_dependency 'rake', '~> 13'
  spec.add_development_dependency 'rspec-benchmark', '~> 0.4'
  spec.add_development_dependency 'rspec-rails', '~> 3.7'
  spec.add_development_dependency 'rspec-retry', '~> 0.6'
  spec.add_development_dependency 'rubocop', '~> 0.59'
  spec.add_development_dependency 'timecop', '~> 0.9'
  spec.add_development_dependency 'vcr', '~> 4.0'
  spec.add_development_dependency 'webmock', '~> 3.4'

  spec.add_dependency 'activerecord-import', '~> 1.5'
  spec.add_dependency 'cash-addr', '~> 0.2'
  spec.add_dependency 'eth', '0.5.11'
  spec.add_dependency 'money-tree', '0.10.0'
  spec.add_dependency 'state_machines-activerecord', '~> 0.5'
  spec.add_dependency 'rqrcode', '~> 2.2'
  spec.add_dependency 'image_processing', '~> 1.12'
end
# rubocop:enable Metrics/BlockLength

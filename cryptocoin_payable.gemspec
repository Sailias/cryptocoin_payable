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

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'cucumber', '~> 3.1'
  spec.add_development_dependency 'database_cleaner', '~> 1.7'
  spec.add_development_dependency 'pg'
  spec.add_development_dependency 'rails', '>= 4.0.0'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec-benchmark', '~> 0.4'
  spec.add_development_dependency 'rspec-rails', '~> 3.7'
  spec.add_development_dependency 'rspec-retry', '~> 0.6'
  spec.add_development_dependency 'rubocop', '~> 0.59'
  spec.add_development_dependency 'sqlite3', '~> 1.3'
  spec.add_development_dependency 'vcr', '~> 4.0'
  spec.add_development_dependency 'webmock', '~> 3.4'

  spec.add_dependency 'activerecord-import', '~> 0.27'
  spec.add_dependency 'cash-addr', '~> 0.2'
  spec.add_dependency 'eth', '0.4.8'
  spec.add_dependency 'money-tree', '0.10.0'
  spec.add_dependency 'state_machine', '~> 1.2'
end
# rubocop:enable Metrics/BlockLength

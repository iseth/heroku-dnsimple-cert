# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "heroku_dnsimple_cert/version"

Gem::Specification.new do |spec|
  spec.name          = "heroku_dnsimple_cert"
  spec.version       = HerokuDnsimpleCert::VERSION
  spec.authors       = ["Timur Vafin", "Seth Horsley"]
  spec.email         = ["isethi@me.com"]

  spec.summary       = "Upload SSL cert from DNSimple to Heroku."
  spec.description   = "Upload SSL cert from DNSimple to Heroku."
  spec.homepage      = "https://github.com/iseth/heroku-dnsimple-cert"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 6.0.0"
  spec.add_dependency "dnsimple"
  spec.add_dependency "dotenv"
  spec.add_dependency "httparty"
  spec.add_dependency "thor"

  spec.add_development_dependency "rake", "~> 10.0"
  
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "bundler-audit"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-rspec"
end

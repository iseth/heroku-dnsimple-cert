module HerokuDnsimpleCert
  class Engine < ::Rails::Engine
    engine_name "heroku_dnsimple_cert"

    config.to_prepare do
      # HerokuDnsimpleCert::CLI.setup
      require "heroku_dnsimple_cert/cli"
    end
  end
end

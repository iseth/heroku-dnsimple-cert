require "thor"
require "pry"
Dotenv.load

module HerokuDnsimpleCert
  class CLI < Thor
    include Thor::Actions
    include HerokuDnsimpleCert::Env

    extend Env

    OPTIONS = %w(dnsimple_token dnsimple_account_id dnsimple_domain dnsimple_common_name heroku_token heroku_app).freeze

    OPTIONS.each do |option|
      option = find_value_by_name(:"heroku_dnsimple_cert", option.downcase.to_sym).to_s
      method_option(option, type: :string, default: option, required: true)
    end

    desc :update, "Create or update Heroku certificate from DNSimple"

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/MethodLength
    def update
      say "Fetching certificate chain from DNSimple for #{options['dnsimple_common_name']} ...", :green
      dnsimple_certificate.certificate_chain

      say "Fetching private key from DNSimple for #{options['dnsimple_common_name']}. ..", :green
      dnsimple_certificate.private_key

      say "Fetching certificates from Heroku app #{options['heroku_app']} ...", :green
      heroku_certificate.certificates

      if heroku_certificate.certificates.any?
        say "Updating existing certificate on Heroku app #{options['heroku_app']} ...", :green
        heroku_certificate.update
      else
        say "Adding new certificate on Heroku app #{options['heroku_app']} ...", :green
        heroku_certificate.create
      end

      say "Done!", :green
    rescue => e
      say "Error adding certificate ...", :red
      say "   Response: #{e}", :red

      abort
    end

    def self.setup
      binding.pry
    end

    private

    def dnsimple_certificate
      @dnsimple_certificate ||= DnsimpleCertificate.new(
        token: options["dnsimple_token"],
        account_id: options["dnsimple_account_id"],
        domain: options["dnsimple_domain"],
        common_name:  options["dnsimple_common_name"]
      )
    end

    def heroku_certificate
      @heroku_certificate ||= HerokuCertificate.new(
        token: options["heroku_token"],
        app: options["heroku_app"],
        certificate_chain: dnsimple_certificate.certificate_chain,
        private_key: dnsimple_certificate.private_key
      )
    end

    def say(message = "", color = nil)
      color = nil unless $stdout.tty?
      super(message.to_s, color)
    end

    # Search for environment variables
    #
    # We must handle a lot of different cases, including the new Rails 6
    # environment separated credentials files which have no nesting for
    # the current environment.
    #
    # 1. Check environment variable
    # 2. Check environment scoped credentials, then secrets
    # 3. Check unscoped credentials, then secrets
    def find_value_by_name(scope, name)
      ENV["#{scope.upcase}_#{name.upcase}"] ||
        credentials&.dig(env, scope, name) ||
        secrets&.dig(env, scope, name) ||
        credentials&.dig(scope, name) ||
        secrets&.dig(scope, name)
    rescue ActiveSupport::MessageEncryptor::InvalidMessage
      Rails.logger.error <<~MESSAGE
        Rails was unable to decrypt credentials. Pay checks the Rails credentials to look for API keys for payment processors.
        Make sure to set the `RAILS_MASTER_KEY` env variable or in the .key file. To learn more, run "bin/rails credentials:help"
        If you're not using Rails credentials, you can delete `config/credentials.yml.enc` and `config/credentials/`.
      MESSAGE
    end

    def env
      Rails.env.to_sym
    end

    def secrets
      Rails.application.secrets
    end

    def credentials
      Rails.application.credentials if Rails.application.respond_to?(:credentials)
    end
  end
end

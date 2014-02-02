require 'google/api_client'
require "google_cells/version"
require "google_cells/spreadsheet"

module GoogleCells
  class << self
    attr_accessor :config, :client
  end

  def self.configure
    self.config ||= Configuration.new
    yield(config)

    self.client = Google::APIClient.new(
      :application_name => 'GoogleCells App',
      :application_version => '0.0.1')

    opts = if config.refresh_token
      auth_refresh_token_opts
    else
      auth_service_account_opts
    end.merge({
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
      audience: 'https://accounts.google.com/o/oauth2/token',
      scope: ['https://www.googleapis.com/auth/drive',
        'https://spreadsheets.google.com/feeds'],
    })

    client.authorization = Signet::OAuth2::Client.new(opts)
    config
  end

  class Configuration
    attr_accessor :service_account_email, :key_secret, :key_file, :refresh_token

    def initialize
      @key_secret = 'notasecret'

      @api_version = 'v2'
      @cached_api_file = "drive-#{@api_version}.cache"
    end
  end

  private

  def self.auth_refresh_token_opts
    {refresh_token: config.refresh_token}
  end

  def self.auth_service_account_opts
    key = Google::APIClient::KeyUtils.load_from_pkcs12(config.key_file, 
      config.key_secret)

    { issuer: config.service_account_email,
      signing_key: key }
  end
end

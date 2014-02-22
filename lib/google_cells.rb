require 'google/api_client'
require 'nokogiri'

require "google_cells/fetcher"
require "google_cells/reader"
require "google_cells/util"
require "google_cells/google_object"
require "google_cells/author"
require "google_cells/cell"
require "google_cells/cell_selector"
require "google_cells/folder"
require "google_cells/row"
require "google_cells/spreadsheet"
require "google_cells/worksheet"
require "google_cells/version"

module GoogleCells
  class << self
    attr_accessor :config, :client
  end

  def self.configure
    self.config ||= Configuration.new
    yield(config)

    self.client = Google::APIClient.new(
      :application_name => 'GoogleCells App',
      :application_version => '0.0.3'
    )
    if config.path_to_credentials_file
      config_from_file
    elsif config.client_id
      config_web_application
    else
      config_service_account
    end
    client.authorization.scope = ['https://www.googleapis.com/auth/drive',
      'https://spreadsheets.google.com/feeds']
    client.authorization.token_credential_uri = 'https://accounts.google.com/o/oauth2/token'

    config
  end

  class Configuration
    attr_accessor :service_account_email, :key_secret, :key_file, :client_id, 
      :client_secret, :path_to_credentials_file

    def initialize
      @key_secret = 'notasecret'

      @api_version = 'v2'
      @cached_api_file = "drive-#{@api_version}.cache"
    end
  end

  private

  def self.config_web_application
    client.authorization.client_id = config.client_id
    client.authorization.client_secret = config.client_secret
  end

  def self.config_service_account
    key = Google::APIClient::KeyUtils.load_from_pkcs12(config.key_file, 
      config.key_secret)
    opts = { issuer: config.service_account_email,
      signing_key: key }

    client.authorization = Signet::OAuth2::Client.new(opts)
    client.authorization.audience = 'https://accounts.google.com/o/oauth2/token'
  end

  def self.config_from_file
    flow = Google::APIClient::FileStorage.new(
      :path => config.path_to_credentials_file
    )
    client.authorization = flow.authorize
  end
end

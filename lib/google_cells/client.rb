require 'google_cells'
require 'google/api_client'

module GoogleCells

  class Client
    
    def initialize()
      config = GoogleCells.config
      key = Google::APIClient::KeyUtils.load_from_pkcs12(config.key_file, 
        config.key_secret)

      @client = Google::APIClient.new(
        :application_name => 'GoogleCells App',
        :application_version => '0.0.1')

      @client.authorization = Signet::OAuth2::Client.new(
        :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
        :audience => 'https://accounts.google.com/o/oauth2/token',
        :scope => ['https://www.googleapis.com/auth/drive',
          'https://spreadsheets.google.com/feeds'],
        :issuer => config.service_account_email,
        :signing_key => key)
    end

    def authorize!
      @client.authorization.fetch_access_token!
    end
  end
end

require 'google_cells'
require 'google/api_client'
require "cgi"

module GoogleCells

  class Client

    def authorize!
      GoogleCells.client.authorization.fetch_access_token!
    end
  end
end

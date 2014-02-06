module GoogleCells

  module Fetcher

    BASE_URL = 'https://spreadsheets.google.com/feeds/spreadsheets/private/full?'

    def raw(url=nil)
      url ||= BASE_URL
      GoogleCells.client.authorization.fetch_access_token!
      res = GoogleCells.client.execute!(
        :http_method => :get,
        :uri => url
      ) 
      res.body
    end
  end
end

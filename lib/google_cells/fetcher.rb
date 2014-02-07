module GoogleCells

  module Fetcher

    BASE_URL = 'https://spreadsheets.google.com/feeds/spreadsheets/private/full'

    def raw(url=nil, params={})
      url ||= BASE_URL
      if !params.empty?
        url << '?' unless url[-1] == "?"
        url << params.to_a.map{|k,v| "#{k}=#{v}"}.join('&')
      end
      GoogleCells.client.authorization.fetch_access_token!
      res = GoogleCells.client.execute!(
        :http_method => :get,
        :uri => url
      ) 
      res.body
    end
  end
end

module GoogleCells

  module Fetcher

    BASE_URL = 'https://spreadsheets.google.com/feeds/spreadsheets/private/full'

    def raw(url=nil, params={})
      url ||= BASE_URL
      res = request(:get, url, url_params: params)
      res.body
    end

    def request(method, url, params={})
      if params[:url_params] && !params[:url_params].empty?
        url << '?' unless url[-1] == "?"
        url << params.to_a.map{|k,v| "#{k}=#{v}"}.join('&')
      end
      GoogleCells.client.authorization.fetch_access_token!
      GoogleCells.client.execute!(
        :http_method => method,
        :uri => url,
        :headers => params[:headers],
        :body => params[:body]
      ) 
    end
  end
end

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
        url << params[:url_params].to_a.map{|k,v| "#{k}=#{v}"}.join('&')
      end

      authorize
      
      GoogleCells.client.execute!(
        :http_method => method,
        :uri => url,
        :headers => params[:headers],
        :body => params[:body]
      ) 
    end

    def authorize
      if !auth.access_token || auth.expired?
        GoogleCells.client.authorization.fetch_access_token!
      end
    end

    private

    def auth
      GoogleCells.client.authorization
    end

  end
end

module GoogleCells

  class Spreadsheet < GoogleCells::GoogleObject

    @permanent_attributes = [ :title, :id, :updated_at, :author, :worksheets_uri ]
    define_accessors

    class << self

      def list
        spreadsheets = []
        uri = 'https://spreadsheets.google.com/feeds/spreadsheets/private/full?'
        GoogleCells.client.authorization.fetch_access_token!
        res = GoogleCells.client.execute!(
          :http_method => :get,
          :uri => uri
        ) 
        doc = Nokogiri.parse(res.body)
        doc.css("feed > entry").each() do |entry|
          args = {
            etag: entry.attribute('gd:etag'),
            title: entry.css("title").text,
            id: entry.css("id").text,
            updated_at: entry.css("updated").text,
            author: Author.new(
              name: entry.css("author/name").text,
              email: entry.css("author/email").text
            ),
            worksheets_uri: entry.css("link[rel='http://schemas.google.com/spreadsheets" + 
              "/2006#worksheetsfeed']")[0]["href"]
          }
          spreadsheets << Spreadsheet.new(args)
        end
        spreadsheets
      end
    end

    def worksheets
      return @worksheets if @worksheets
      GoogleCells.client.authorization.fetch_access_token!
      res = GoogleCells.client.execute!(
        :http_method => :get,
        :uri => worksheets_uri
      ) 
      doc = Nokogiri.parse(res.body)
      @worksheets = []
      doc.css("entry").each() do |entry|
        args = {
          etag: entry.attribute('gd:etag'),
          title: entry.css("title").text,
          updated_at: entry.css("updated").text,
          cells_uri: entry.css(
            "link[rel='http://schemas.google.com/spreadsheets/2006#cellsfeed']"
            )[0]["href"],
          lists_uri: entry.css(
            "link[rel='http://schemas.google.com/spreadsheets/2006#listfeed']"
            )[0]["href"],
          spreadsheet: self
        }
      end
      return @worksheets
    end
  end
end

module GoogleCells

  class Spreadsheet < GoogleCells::GoogleObject

    @permanent_attributes = [ :title, :id, :updated_at, :author, :url ]
    define_accessors

    class << self

      def list
        uri = 'https://spreadsheets.google.com/feeds/spreadsheets/private/full?'

        GoogleCells.client.authorization.fetch_access_token!

        res = GoogleCells.client.execute!(
          :http_method => :get,
          :uri => uri
        ) 
        doc = Nokogiri.parse(res.body)

        spreadsheets = []
        doc.css("feed > entry").each() do |entry|
          args = {
            title: entry.css("title").text,
            id: entry.css("id").text,
            updated_at: entry.css("updated").text,
            author: Author.new(
              name: entry.css("author/name").text,
              email: entry.css("author/email").text
            ),
            url: entry.css("link[rel='http://schemas.google.com/spreadsheets" + 
              "/2006#worksheetsfeed']")[0]["href"]
          }

          spreadsheets << Spreadsheet.new(args)
        end

        spreadsheets
      end
    end
  end
end

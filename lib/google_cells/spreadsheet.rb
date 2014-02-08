require 'google_cells/worksheet'
require 'json'

module GoogleCells

  class Spreadsheet < GoogleCells::GoogleObject
    extend Reader

    @permanent_attributes = [ :title, :id, :updated_at, :author, :worksheets_uri,
      :key ]
    define_accessors

    class << self

      def list
        spreadsheets = []
        each_entry do |entry|
          args = parse_from_entry(entry)
          spreadsheets << Spreadsheet.new(args)
        end
        spreadsheets
      end

      def get(key)
        spreadsheet = nil
        url = "https://spreadsheets.google.com/feeds/worksheets/#{key}/private/full"
        each_entry do |entry|
          args = parse_from_entry(entry)
          spreadsheet = Spreadsheet.new(args.merge(key:key))
          break
        end
        spreadsheet
      end

      def copy(key)
        url = "https://www.googleapis.com/drive/v2/files/#{key}/copy"
        res = request(:post, url)
        get(res.data['id'])
      end
    end

    def worksheets
      return @worksheets if @worksheets
      @worksheets = []
      self.class.each_entry(worksheets_uri) do |entry|
        args = {
          title: entry.css("title").text,
          updated_at: entry.css("updated").text,
          cells_uri: entry.css(
            "link[rel='http://schemas.google.com/spreadsheets/2006#cellsfeed']"
            )[0]["href"],
          lists_uri: entry.css(
            "link[rel='http://schemas.google.com/spreadsheets/2006#listfeed']"
            )[0]["href"],
          row_count: entry.css("gs|rowCount").text.to_i,
          col_count: entry.css("gs|colCount").text.to_i,
          spreadsheet: self
        }
        @worksheets << Worksheet.new(args)
      end
      return @worksheets
    end

    private

    def self.parse_from_entry(entry)
      { title: entry.css("title").text,
        id: entry.css("id").text,
        updated_at: entry.css("updated").text,
        author: Author.new(
          name: entry.css("author/name").text,
          email: entry.css("author/email").text
        ),
        worksheets_uri: entry.css("link[rel='http://schemas.google.com/spreadsheets" + 
          "/2006#worksheetsfeed']")[0]["href"]
      }
    end
  end
end

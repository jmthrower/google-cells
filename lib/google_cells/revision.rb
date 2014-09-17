module GoogleCells
  class Revision < GoogleCells::GoogleObject
    extend UrlHelper
    extend Fetcher

    @permanent_attributes = [ :id, :updated_at, :spreadsheet_key, :etag,
      :author ]
    define_accessors

    class << self
    
      def list(key)
        revisions = []
        res = request(:get, self.revisions_uri(key))
        JSON.parse(res.body)['items'].each do |entry|
          args = parse_from_entry(entry)
          revisions << Revision.new(args.merge(spreadsheet_key: key))
        end
        revisions.sort{|a,b| a.updated_at <=> b.updated_at}
      end
    end

    def spreadsheet
      @spreadsheet ||= Spreadsheet.get(self.spreadsheet_key)
    end

    private

    def self.parse_from_entry(entry)
      { id: entry['id'],
        updated_at: entry['modifiedDate'],
        etag: entry['etag'],
        author: Author.new(
          name: entry['lastModifyingUserName'],
          email: entry['lastModifyingUser']['emailAddress']
        )
      }
    end
  end
end



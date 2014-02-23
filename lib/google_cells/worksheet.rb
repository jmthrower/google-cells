require 'cgi'

module GoogleCells
  class Worksheet < GoogleCells::GoogleObject
    include Fetcher
    include Util

    @permanent_attributes = [ :etag, :title, :updated_at, :cells_uri,
      :lists_uri, :spreadsheet, :row_count, :col_count ]
    define_accessors

    def rows
      GoogleCells::CellSelector::RowSelector.new(self)
    end


    def save!
      return if @changed_cells.nil? || @changed_cells.empty?
      batch_url = concat_url(cells_uri, "/batch")
      request(:post, batch_url, body: to_xml, headers:{
        "Content-Type" => "application/atom+xml"})
      @changed_cells = {}
      true
    end

    def track_changes(cell)
      @changed_cells ||= {}
      @changed_cells[cell.title] = cell # track only most recent change
      nil
    end

    private

    def to_xml
      xml = <<-EOS
  <feed xmlns="http://www.w3.org/2005/Atom"
        xmlns:batch="http://schemas.google.com/gdata/batch"
        xmlns:gs="http://schemas.google.com/spreadsheets/2006">
    <id>#{e(self.cells_uri)}</id>
EOS
      @changed_cells.each do |title, cell|        
        xml << cell.to_xml
      end
      xml << <<-"EOS"
  </feed>
EOS
    end
  end
end


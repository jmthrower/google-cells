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
      response = request(:post, batch_url, body: to_xml, headers:{
        "Content-Type" => "application/atom+xml", "If-Match" => "*"})
      doc = Nokogiri.parse(response.body)

      doc.css("atom|entry").each{|entry| check_entry_for_errors!(entry) }
      @changed_cells = {}
      true
    end

    def track_changes(cell)
      @changed_cells ||= {}
      @changed_cells[cell.title] = cell # track only most recent change
      nil
    end

    private

    class UpdateError < StandardError ; end

    def check_entry_for_errors!(entry)
      check_for_batch_error!(entry)
      check_for_cell_error!(entry)
    end

    def check_for_batch_error!(entry)
      return unless entry.css("batch|interrupted")[0]
      raise UpdateError, "Update failed: #{interrupted["reason"]}"
    end

    def check_for_cell_error!(entry)
      return if (entry.css("batch|status").first["code"] =~ /^2/)
      raise UpdateError, "Update failed for cell #{entry.css("atom|id").text
        }: #{entry.css("batch|status").first["reason"]}"
    end

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


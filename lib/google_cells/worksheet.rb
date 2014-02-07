module GoogleCells
  class Worksheet < GoogleCells::GoogleObject
    @permanent_attributes = [ :etag, :title, :updated_at, :cells_uri,
      :lists_uri, :spreadsheet, :row_count, :col_count ]
    define_accessors

    def rows
      GoogleCells::CellSelector.new(self)
    end
  end
end


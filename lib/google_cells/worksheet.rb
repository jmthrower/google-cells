module GoogleCells
  class Worksheet < GoogleCells::GoogleObject
    @permanent_attributes = [ :etag, :title, :updated_at, :cells_uri,
      :lists_uri, :spreadsheet ]
    define_accessors
  end
end


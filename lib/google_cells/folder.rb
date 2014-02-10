module GoogleCells
  class Folder < GoogleCells::GoogleObject
    @permanent_attributes = [ :key, :spreadsheet ]
    define_accessors
  end
end


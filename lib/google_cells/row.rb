module GoogleCells

  class Row < GoogleCells::GoogleObject
    @permanent_attributes = [:number, :cells, :worksheet]
    define_accessors
  end
end

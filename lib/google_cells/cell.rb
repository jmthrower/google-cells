module GoogleCells
  class Cell < GoogleCells::GoogleObject
    @permanent_attributes = [:title, :id, :value, :input_value, :numeric_value]
    define_accessors
  end
end



module GoogleCells
  class Cell < GoogleCells::GoogleObject
    @permanent_attributes = [:title, :id, :value, :input_value, :numeric_value, 
      :row, :col, :edit_url]
    define_accessors
  end
end



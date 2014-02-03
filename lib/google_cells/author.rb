module GoogleCells
  class Author < GoogleCells::GoogleObject
    @permanent_attributes = [ :name, :email ]
    define_accessors
  end
end


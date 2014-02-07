module GoogleCells
  class CellSelector
    attr_accessor :min_row, :max_row, :min_col, :max_col, :worksheet

    def initialize(ws)
      @worksheet = ws
      @min_row = 1
      @max_row = worksheet.row_count
      @min_col = 1
      @max_col = worksheet.col_count
    end
  end
end


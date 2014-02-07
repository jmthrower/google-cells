module GoogleCells
  class CellSelector

    class RowSelector < CellSelector

      DEFAULT_BATCH_SIZE = 10

      def find_each(opts={}, &block)
        size = (opts[:batch_size] || DEFAULT_BATCH_SIZE).to_i
        rnum = @min_row
        loop do
          last = [rnum + size, worksheet.row_count].min
          break if rnum > last
          get_cells(rnum, last).each do |cells|
            yield Row.new(cells:cells, number:rnum, worksheet:worksheet)
            rnum += 1
          end
        end
      end

      def each
        self.find_each(batch_size:worksheet.row_count){|c| yield c}
      end

      def from(num)
        @min_row = num.to_i
        self
      end

      def to(num)
        @max_row = num.to_i
        self
      end

      private

      def get_cells(start, last)
        cells = []
        each_entry(worksheet.cells_uri, 'return-empty' => true, 
          'min-row' => start, 'max-row' => last) do |entry|

          gscell = entry.css("gs|cell")[0]
          cell = Cell.new
          cell.id = entry.css("id").text
          cell.value = gscell.inner_text
          cell.row = gscell["row"].to_i()
          cell.col = gscell["col"].to_i()
          cell.edit_url = entry.css("link[rel='edit']")[0]["href"]

          cells[cell.row - start] ||= []
          cells[cell.row - start][cell.col - 1] = cell
        end
        cells
      end
    end
  end
end

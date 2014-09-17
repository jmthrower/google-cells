module GoogleCells
  class CellSelector

    class RowSelector < CellSelector

      DEFAULT_BATCH_SIZE = 10

      def find_each(opts={}, &block)
        size = (opts[:batch_size] || DEFAULT_BATCH_SIZE).to_i
        rnum = @min_row
        loop do
          last = [rnum + size, @max_row].min
          break if rnum > last
          get_cells(rnum, last).each do |cells|
            yield Row.new(cells:cells, number:rnum, worksheet:worksheet)
            rnum += 1
          end
        end
      end

      def each
        all.each{|c| yield c}
      end

      def all
        @rows = []
        self.find_each(batch_size:@max_row - @min_row){|r| @rows << r}
        @rows
      end

      def first
        all.first
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
        each_entry(worksheet.cells_uri, 'return-empty' => 'true', 
          'min-row' => start.to_s, 'max-row' => last.to_s) do |entry|
          args = parse_from_entry(entry)
          cell = Cell.new(args)
          cells[cell.row - start] ||= []
          cells[cell.row - start][cell.col - 1] = cell
        end
        cells
      end
    end

    def parse_from_entry(entry)
      gscell = entry.css("gs|cell")[0]
      {
        id: entry.css("id").text,
        title: entry.css("title").text,
        value: gscell.inner_text,
        row: gscell["row"].to_i,
        col: gscell["col"].to_i,
        edit_url: entry.css("link[rel='edit']")[0]["href"],
        input_value: gscell["inputValue"],
        numeric_value: gscell["numericValue"],
        worksheet: self.worksheet
      }
    end
  end
end

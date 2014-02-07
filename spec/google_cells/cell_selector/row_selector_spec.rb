require 'spec_helper'

describe GoogleCells::CellSelector::RowSelector do

  let(:subject) do 
    w = nil
    VCR.use_cassette('google_cells/spreadsheet/cell_selector/worksheet', 
      :decode_compressed_response => true) do |c|
      s = GoogleCells::Spreadsheet.list.first
      w = s.worksheets.first
    end
    GoogleCells::CellSelector::RowSelector.new(w)
  end

  describe "#find_each" do
    
    it "iterates over rows specified in cell selector" do
      count = 0

      VCR.use_cassette('google_cells/cell_selector/find_each', 
        :decode_compressed_response => true) do |c|
        subject.find_each do |r|
          count += 1
          r.class.should eq GoogleCells::Row
        end
      end
      count.should eq 31
    end

    context "optional batch sizes" do
      it "fetches in batches 10" do
        batch = 10
        subject.should_receive(:get_cells).exactly(4).times.and_return((1..batch).to_a)
        subject.find_each(batch_size:batch){|r| r}
      end
      it "fetches in batches 3" do
        batch = 3
        subject.should_receive(:get_cells).exactly(11).times.and_return((1..batch).to_a)
        subject.find_each(batch_size:batch){|r| r}
      end
    end
  end

=begin
  spreadsheet.rows.each do |r|
    r.cells.each do |cell|
      p r
    end
  end

  spreadsheet.rows.from(1).to(4).each do |r|
  end
  spreadsheet.rows.all
  spreadsheet.columns.all
  spreadsheet.cells.all
  spreadsheet.columns.each do |c|
=end
end


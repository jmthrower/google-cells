require 'spec_helper'

describe GoogleCells::Worksheet do

  it { should respond_to(:etag) }
  it { should respond_to(:title) }
  it { should respond_to(:updated_at) }
  it { should respond_to(:cells_uri) }
  it { should respond_to(:lists_uri) }
  it { should respond_to(:spreadsheet) }
  it { should respond_to(:row_count) }
  it { should respond_to(:col_count) }
  
  let(:worksheet) do 
    w = nil
    VCR.use_cassette('google_cells/spreadsheet/list', 
      :decode_compressed_response => true) do |c|
      s = GoogleCells::Spreadsheet.list.first
      w = s.worksheets.first
    end
    w
  end

  describe "rows" do

    it "returns a row type cell selector object" do
      cs = worksheet.rows
      cs.class.should eq GoogleCells::CellSelector::RowSelector
    end
  end
end


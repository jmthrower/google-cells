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

  describe "#save" do

    it "tracks all changed cells" do
      VCR.use_cassette('google_cells/spreadsheet/list', 
        :decode_compressed_response => true) do |c|
        s = GoogleCells::Spreadsheet.list.first
        w = s.worksheets.first
        c = GoogleCells::Cell.new(:worksheet => w)
        w.instance_variable_get(:@changed_cells).should_not be
        c.input_value = "a different name"
        w.instance_variable_get(:@changed_cells).should eq ({c.title => c})
      end
    end

    it "saves cells" do
      VCR.use_cassette('google_cells/worksheet/save', 
        :decode_compressed_response => true) do |c|
        s = GoogleCells::Spreadsheet.list.first
        w = s.worksheets.first

        c = GoogleCells::Cell.new(
          :title=>"A1", 
          :id=>"https://spreadsheets.google.com/feeds/cells/'+
            't-9Bgdk4FJIM8BDqIDHpBCw/od6/private/full/R1C1", 
          :value=>"", 
          :numeric_value=>nil, 
          :row=>1, 
          :col=>1, 
          :edit_url=>"https://spreadsheets.google.com/feeds/cells/'+
            't-9Bgdk4FJIM8BDqIDHpBCw/od6/private/full/R1C1/bzwjv",
          :input_value=> "a new name",
          :worksheet => w
        )
        w.track_changes(c)
        w.save!.should be
      end
    end
  end
end


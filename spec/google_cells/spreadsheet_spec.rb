require 'spec_helper'

describe GoogleCells::Spreadsheet do

  it { should respond_to(:title) }
  it { should respond_to(:id) }
  it { should respond_to(:updated_at) }
  it { should respond_to(:author) }
  it { should respond_to(:worksheets_uri) }

  describe ".copy" do

    it "returns a new spreadsheet object" do
      VCR.use_cassette('google_cells/spreadsheet/copy', 
        :decode_compressed_response => true) do |c|
        s = GoogleCells::Spreadsheet.get('SPREADSHEET_KEY')
        c = GoogleCells::Spreadsheet.copy(s.key)
        s.key.should_not eq c.key
        s.title.should eq c.title
        svals = s.worksheets[0].rows.first.cells.map(&:value)
        cvals = c.worksheets[0].rows.first.cells.map(&:value)
        svals.should eq cvals
      end
    end
  end

  describe ".list" do

    it "returns a list of Google Spreadsheets" do
      objs = nil
      VCR.use_cassette('google_cells/spreadsheet', 
        :decode_compressed_response => true) do |c|
        objs = GoogleCells::Spreadsheet.list
      end
      objs.count.should eq 1
      s = objs.first
      s.title.should eq "Businesses"
      s.id.should eq 'https://spreadsheets.google.com/feeds/spreadsheets/' + 
        'private/full/myspreadsheetid'
      s.updated_at.should eq '2014-01-31T20:37:14.168Z'

      a = s.author
      a.name.should eq 'jessica'
      a.email.should eq 'myemail@mydomain.com'
    end
  end

  describe ".get" do

    it "retrieves a google spreadsheet by id" do
      s = nil
      VCR.use_cassette('google_cells/spreadsheet/get', 
        :decode_compressed_response => true) do |c|
        s = GoogleCells::Spreadsheet.get('myspreadsheetid')
      end
      s.class.should eq GoogleCells::Spreadsheet
      s.title.should eq 'Pokemon'
      s.id.should eq 'https://spreadsheets.google.com/feeds/spreadsheets/' + 
        'private/full/myspreadsheetid'
      s.updated_at.should eq '2014-02-06T23:32:40.396Z'
      s.author.name.should eq 'jessica'
      s.author.email.should eq 'myemail@mydomain.com'
    end
  end

  describe "#worksheets" do

    it "returns a list of Google worksheets" do
      spreadsheet = nil
      VCR.use_cassette('google_cells/spreadsheet', 
        :decode_compressed_response => true) do |c|
        spreadsheet = GoogleCells::Spreadsheet.list.first
      end
      VCR.use_cassette('google_cells/worksheets', 
        :decode_compressed_response => true) do
        spreadsheet.worksheets
      end
      spreadsheet.worksheets.count.should eq 2
      w = spreadsheet.worksheets.first
      w.title.should eq 'Businesses'
      w.updated_at.should eq '2014-01-31T20:37:14.168Z'
      w.cells_uri.should eq 'https://spreadsheets.google.com/feeds/cells/' +
        'myspreadsheetid/od6/private/full'
      w.lists_uri.should eq 'https://spreadsheets.google.com/feeds/list/' + 
        'myspreadsheetid/od6/private/full'
      w.row_count.should eq 100
      w.col_count.should eq 23
      w.spreadsheet.should eq spreadsheet
    end
  end
end

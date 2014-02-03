require 'spec_helper'

describe GoogleCells::Spreadsheet do

  it { should respond_to(:title) }
  it { should respond_to(:id) }
  it { should respond_to(:updated_at) }
  it { should respond_to(:author) }
  it { should respond_to(:worksheets_uri) }

  describe ".list" do

    it "returns a list of Google Spreadsheets" do
      objs = nil
      VCR.use_cassette('google_cells/spreadsheet', :decode_compressed_response => true) do |c|
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

  describe "#worksheets" do

    it "returns a list of Google worksheets" do
      spreadsheet = nil
      VCR.use_cassette('google_cells/spreadsheet', :decode_compressed_response => true) do |c|
        spreadsheet = GoogleCells::Spreadsheet.list.first
      end
      VCR.use_cassette('google_cells/worksheets', :decode_compressed_response => true) do
        spreadsheet.worksheets
      end
      spreadsheet.worksheets.count.should eq 2
      w = spreadsheet.worksheets.last
      w.title.should eq 'Metadata'
      w.updated_at.should eq '2014-01-31T20:35:44.452Z'
      w.cells_uri.should eq 'https://spreadsheets.google.com/feeds/cells/' + 
        'myspreadsheetid/ocw/private/full'
      w.lists_uri.should eq 'https://spreadsheets.google.com/feeds/list/' + 
        'myspreadsheetid/ocw/private/full'
      w.spreadsheet.should eq spreadsheet
    end
  end
end

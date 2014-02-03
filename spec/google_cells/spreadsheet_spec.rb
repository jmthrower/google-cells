require 'spec_helper'

describe GoogleCells::Spreadsheet do

  it { should respond_to(:title) }
  it { should respond_to(:id) }
  it { should respond_to(:updated_at) }
  it { should respond_to(:author) }
  it { should respond_to(:url) }

  describe "#list" do

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
end

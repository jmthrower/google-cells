require 'spec_helper'

describe GoogleCells::Spreadsheet do

  let(:klass){subject.class}

  it { should respond_to(:title) }
  it { should respond_to(:id) }
  it { should respond_to(:updated_at) }
  it { should respond_to(:author) }
  it { should respond_to(:worksheets_uri) }

  describe ".share" do

    let(:body){{role:'owner',type:'user',value:'me@me.com'}}

    it "creates a new permission for the passed args" do
      klass.should_receive(:request).with(:post, "https://www.googleapis.com" + 
        "/drive/v2/files/myspreadsheetid/permissions", {:body=>"{\"role\":\"" + 
        "owner\",\"type\":\"user\",\"value\":\"me@me.com\"}", :url_params=>{},
        :headers=>{"Content-Type"=>"application/json"}})
      klass.share('myspreadsheetid', body)
    end
  end

  describe ".copy" do

    it "returns a new spreadsheet object" do
      VCR.use_cassette('google_cells/spreadsheet/copy', 
        :decode_compressed_response => true) do |c|
        s = klass.get('SPREADSHEET_KEY')
        c = klass.copy(s.key)
        s.key.should_not eq c.key
        s.title.should eq c.title
        svals = s.worksheets[0].rows.first.cells.map(&:value)
        cvals = c.worksheets[0].rows.first.cells.map(&:value)
        svals.should eq cvals
      end
    end

    it "optionally assigns a folder key" do
      VCR.use_cassette('google_cells/spreadsheet/copy/folder', 
        :decode_compressed_response => true) do |c|
        fkey = 'parentid'
        s = klass.get('myspreadsheetkey')
        c = klass.copy(s.key, folder_key:fkey)
        c.folders.count.should eq 1
        c.folders.first.key.should be
      end
    end
  end

  describe ".list" do

    it "returns a list of Google Spreadsheets" do
      objs = nil
      VCR.use_cassette('google_cells/spreadsheet', 
        :decode_compressed_response => true) do |c|
        objs = klass.list
      end
      objs.count.should eq 1
      s = objs.first
      s.title.should eq "Businesses"
      s.id.should eq 'https://spreadsheets.google.com/feeds/spreadsheets/' + 
        'private/full/myspreadsheetid'
      s.updated_at.should eq '2014-01-31T20:37:14.168Z'
      s.key.should eq 'myspreadsheetkey'

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
        s = klass.get('myspreadsheetid')
      end
      s.class.should eq klass
      s.title.should eq 'Pokemon'
      s.id.should eq 'https://spreadsheets.google.com/feeds/spreadsheets/' + 
        'private/full/myspreadsheetid'
      s.updated_at.should eq '2014-02-06T23:32:40.396Z'
      s.author.name.should eq 'jessica'
      s.author.email.should eq 'myemail@mydomain.com'
    end
  end

  describe "#enfold" do

    it "adds a folder for self" do
      VCR.use_cassette('google_cells/spreadsheet/enfold', 
        :decode_compressed_response => true) do |c|
        s = klass.get('myspreadsheetid')
        s.instance_variable_set(:@folders, [])
        s.enfold('folderid').should be
        folders = s.instance_variable_get(:@folders)
        folders.count.should eq 1
        folders.first.key.should eq 'folderid'
      end
    end
  end

  describe "#folders" do

    it "retrieves folder information for doc" do
      VCR.use_cassette('google_cells/spreadsheet/folders', 
        :decode_compressed_response => true) do |c|
        s = klass.get('copiedspreadsheetkey')
        s.folders.count.should eq 1
        f = s.folders.first
        f.class.should eq GoogleCells::Folder
        f.key.should eq 'parentid'
      end
    end
  end

  describe "#worksheets" do

    it "returns a list of Google worksheets" do
      spreadsheet = nil
      VCR.use_cassette('google_cells/spreadsheet', 
        :decode_compressed_response => true) do |c|
        spreadsheet = klass.list.first
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

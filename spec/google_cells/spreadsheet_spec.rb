require 'spec_helper'

describe GoogleCells::Spreadsheet do
  
  let(:klass){GoogleCells::Spreadsheet}

  it { should respond_to(:title) }
  it { should respond_to(:key) }
  it { should respond_to(:updated_at) }
  it { should respond_to(:author) }

  describe ".share" do

    let(:body){{role:'owner',type:'user',value:'me@me.com'}}

    it "creates a new permission for the passed args" do
      klass.should_receive(:request).with(:post, "https://www.googleapis.com" + 
        "/drive/v2/files/0AsfWTr-e4bf1dFVFRWtuSFJWTm1XeWhRdUt2MWwtQnc/"+
        "permissions", {:body=>"{\"role\":\"" + "owner\",\"type\":\"user\"" + 
        ",\"value\":\"me@me.com\"}", :url_params=>{},
        :headers=>{"Content-Type"=>"application/json"}})
      klass.share('0AsfWTr-e4bf1dFVFRWtuSFJWTm1XeWhRdUt2MWwtQnc', body)
    end
  end

  describe ".copy" do

    before(:each) do
      @s, @c = nil
      VCR.use_cassette('google_cells/spreadsheet/copy') do
        @s = GoogleCells::Spreadsheet.list.first
        @c = klass.copy(s.key)
      end
    end
    let(:s){ @s }

    context "new copy" do
      subject{ @c }

      its(:key){ should_not eq s.key }
      its(:title){ should eq s.title }

      it "should have same content" do
        VCR.use_cassette('google_cells/spreadsheet/copy/content') do
          svals = s.worksheets[0].rows.first.cells.map(&:value)
          cvals = @c.worksheets[0].rows.first.cells.map(&:value)
          svals.should eq cvals
        end
      end
    end
  end

  describe ".list" do

    before(:each) do
      @list = []
      VCR.use_cassette('google_cells/spreadsheet/list') do |c|
        @list = klass.list
      end
    end
    let(:list){ @list }

    it "returns a list" do
      list.count.should eq 3
    end

    it "returns spreadsheet objects" do
      list.each{|s| s.class.should eq subject.class }
    end

    context "loading new spreadsheets correcty" do
      subject {list.first}

      its(:title){ should eq "My Spreadsheet" }
      its(:updated_at){ should eq '2014-02-23T04:52:51.908Z' }
      its(:key){ should eq '0ApTxW-6l0Ch_dHFyNHNwX0NjTHVIVk9ZS2duQ2ptUlE' }

      context "author" do
        subject {list.first.author}

        its(:name){ should eq '194578754295' }
        its(:email){ should eq '194578754295@developer.gserviceaccount.com' }
      end
    end
  end

  describe ".get" do

    before(:each) do
      @s = nil
      VCR.use_cassette('google_cells/spreadsheet/get') do
        @s = klass.get('0AsfWTr-e4bf1dFVFRWtuSFJWTm1XeWhRdUt2MWwtQnc')
      end
    end
    subject{ @s }

    its(:class){ should eq klass }
    its(:title){ should eq 'My Spreadsheet' }
    its(:updated_at){ should eq '2014-02-23T02:25:18.152Z' }

    context "author" do
      subject{ @s.author }
      its(:name){ should eq '194578754295' }
#      its(:email){ should eq '194578754295@developer.gserviceaccount.com' }
    end
  end

  describe "#enfold" do

    before(:each) do
      @s = nil
      VCR.use_cassette('google_cells/spreadsheet/enfold') do
        @s = GoogleCells::Spreadsheet.list.first
        @s.instance_variable_set(:@folders, [])
        @s.enfold('0B5TxW-6l0Ch_elJwQlVMaGcwTjA')
      end
    end
    
    context "folders" do
      subject{ @s.instance_variable_get(:@folders) }
      its(:count){ should eq 1 }

      it "sets key" do
        subject.first.key.should eq '0B5TxW-6l0Ch_elJwQlVMaGcwTjA'
      end
    end
  end

  describe "#folders" do

    before(:each) do
      @s = nil
      VCR.use_cassette('google_cells/spreadsheet/folders') do
        @s = GoogleCells::Spreadsheet.list.first
        @s.folders
      end
    end
    it{ @s.folders.count.should eq 1 }

    context "folders" do
      subject{ @s.folders.first }

      its(:class){ should eq GoogleCells::Folder }
      its(:key){ should eq '0AJTxW-6l0Ch_Uk9PVA' }
    end
  end

  describe "#worksheets" do

    before(:each) do
      @s = nil
      VCR.use_cassette('google_cells/spreadsheet/worksheets') do
        @s = klass.list.first
        @s.worksheets.count.should eq 1
      end
    end
    context "worksheets" do
      subject{ @s.worksheets.first }
      
      its(:title){ should eq 'Sheet1' }
      its(:updated_at){ should eq '2014-02-23T02:25:18.152Z' }
      its(:cells_uri){ should eq 'https://spreadsheets.google.com/feeds/'+
        'cells/0ApTxW-6l0Ch_dHFyNHNwX0NjTHVIVk9ZS2duQ2ptUlE/od6/private/full' }
      its(:lists_uri){ should eq 'https://spreadsheets.google.com/feeds/'+
        'list/0ApTxW-6l0Ch_dHFyNHNwX0NjTHVIVk9ZS2duQ2ptUlE/od6/private/full' }
      its(:row_count){ should eq 100 }
      its(:col_count){ should eq 18 }
      its(:spreadsheet){ should eq @s }
    end
  end

  describe "#revisions" do

    before(:each) do
      @s, @revisions = VCR.use_cassette('google_cells/revisions/list') do |c|
        s = GoogleCells::Spreadsheet.get('1ZRAzPpO--MiXWcIbU_V7YdMlxNZ62hfp4U2HYjis1ls')
        [ s, s.revisions ]
      end
    end

    it "returns a list of revisions" do
      @revisions.each{|r| r.class.should eq GoogleCells::Revision}
    end

    it "assigns self as spreadsheet" do
      @revisions.first.spreadsheet.should eq @s
    end
  end
end

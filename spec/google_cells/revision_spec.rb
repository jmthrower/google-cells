require 'spec_helper'

describe GoogleCells::Revision do

  it { should respond_to(:etag) }
  it { should respond_to(:id) }
  it { should respond_to(:updated_at) }
  it { should respond_to(:spreadsheet_key) }
  it { should respond_to(:spreadsheet) }
  it { should respond_to(:author) }

  let(:revisions) do
    VCR.use_cassette('google_cells/revisions/list') do |c|
      GoogleCells::Revision.list('1ZRAzPpO--MiXWcIbU_V7YdMlxNZ62hfp4U2HYjis1ls')
    end
  end

  describe ".list" do

    it "returns a list of revisions" do
      revisions.count.should eq 3
      revisions.first.class.should eq GoogleCells::Revision
    end

    it "returns revisions with attributes" do
      r = revisions.last
      r.id.should eq "22"
      r.etag.should be
      r.updated_at.should be
      r.spreadsheet_key.should be
    end

    it "returns revisions with author info" do
      r = revisions.last
      r.author.class.should eq GoogleCells::Author
      r.author.name.should eq "Jessica Thrower"
    end
  end
end

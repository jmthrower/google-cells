require 'spec_helper'

describe GoogleCells::Fetcher do

  let(:object) do
    obj = Object.new
    obj.extend(GoogleCells::Fetcher)
    obj
  end

  describe "#raw" do
    
    it "returns the raw xml body of an http GET response" do
      VCR.use_cassette('google_cells/fetcher', :decode_compressed_response => true) do |c|
        doc = object.raw
        doc.should_not be_empty
        Nokogiri::XML(doc).errors.should be_empty
      end
    end
  end
end

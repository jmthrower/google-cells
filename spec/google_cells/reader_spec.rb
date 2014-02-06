require 'spec_helper'

describe GoogleCells::Reader do

  let(:object) do
    obj = Object.new
    obj.extend(GoogleCells::Reader)
    obj
  end

  describe "#each_entry" do
    
    it "iterates over raw xml entries" do
      VCR.use_cassette('google_cells/reader', :decode_compressed_response => true) do |c|
        count = 0
        object.each_entry do |e|
          e.class.should eq Nokogiri::XML::Document
          count +=1
        end
        count.should eq 2
      end
    end
  end
end

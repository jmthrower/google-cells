require 'spec_helper'

describe GoogleCells::UrlHelper do

  class TestClass
    include GoogleCells::UrlHelper
    attr_accessor :key

    def initialize(key)
      @key = key
    end
  end

  subject do 
    s = TestClass.new("12345")
  end

  its(:worksheets_uri){ should eq "https://spreadsheets.google.com/feeds/" + 
    "worksheets/12345/private/full"}
end

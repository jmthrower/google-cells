require 'spec_helper'

describe GoogleCells::UrlHelper do

  class TestClass
    extend GoogleCells::UrlHelper
  end

  subject{ TestClass }

  it "returns worksheets uri" do
    subject.worksheets_uri('12345').should eq "https://spreadsheets.google."+
      "com/feeds/worksheets/12345/private/full"
  end
end

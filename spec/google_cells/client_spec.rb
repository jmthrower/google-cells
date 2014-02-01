require 'spec_helper'

describe GoogleCells::Client do

  before(:each) do
    Google::APIClient::KeyUtils.stub(:load_from_pkcs12)
  end

  it "initializes using GoogleCells config" do
    GoogleCells.should_receive(:config).and_return(GoogleCells::Configuration.new)
    GoogleCells::Client.new
  end
end

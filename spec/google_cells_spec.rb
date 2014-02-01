require 'spec_helper'

describe GoogleCells do

  it "can be configured" do
    email = "test@test.com"
    GoogleCells.configure do |config|
      config.service_account_email = email
    end

    GoogleCells.config.service_account_email.should eq email
  end
end

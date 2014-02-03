require 'spec_helper'

describe GoogleCells::Worksheet do

  it { should respond_to(:etag) }
  it { should respond_to(:title) }
  it { should respond_to(:updated_at) }
  it { should respond_to(:cells_uri) }
  it { should respond_to(:lists_uri) }
  it { should respond_to(:spreadsheet) }
end


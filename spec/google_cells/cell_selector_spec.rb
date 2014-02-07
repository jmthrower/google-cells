require 'spec_helper'

describe GoogleCells::CellSelector do

  let(:subject) do 
    w = nil
    VCR.use_cassette('google_cells/spreadsheet/list', 
      :decode_compressed_response => true) do |c|
      s = GoogleCells::Spreadsheet.list.first
      w = s.worksheets.first
    end
    GoogleCells::CellSelector.new(w)
  end

  it { should respond_to(:min_row) }
  it { should respond_to(:max_row) }
  it { should respond_to(:min_col) }
  it { should respond_to(:max_col) }
  it { should respond_to(:worksheet) }

  context "default values should be derived from worksheet" do
    its(:min_row){ should eq 1 }
    its(:max_row){ should eq 651 }
    its(:min_col){ should eq 1 }
    its(:max_col){ should eq 88 }
  end
end

require 'spec_helper'

describe GoogleCells::GoogleObject do

  context "subclass declaration" do

    class TestObject < GoogleCells::GoogleObject
      @permanent_attributes = %w{ name email }
      define_accessors
    end
    
    it "automatically generates accessors for perm attribs" do
      o = TestObject.new
      o.should respond_to :name
      o.should respond_to :email
    end
  end
end

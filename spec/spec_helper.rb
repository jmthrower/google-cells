require 'rspec'
require 'nokogiri'
require 'webmock/rspec'
require 'vcr'

require File.dirname(__FILE__) + '/../lib/google_cells'

# Contains private keys and VCR filtering config for testing, and is not checked
# into source control
#
# To use, copy and replace your own values from private_spec_helper.sample.rb
require 'private_spec_helper.sample' 
require 'private_spec_helper' 


VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :webmock
end



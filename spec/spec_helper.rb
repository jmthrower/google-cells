require 'rspec'
require 'nokogiri'
require 'webmock/rspec'
require 'vcr'

require File.dirname(__FILE__) + '/../lib/google_cells'

WebMock.disable_net_connect!

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.default_cassette_options = { 
    :match_requests_on =>  [:method, :uri],
    :decode_compressed_response => true,
    :allow_playback_repeats => true
  }
  c.hook_into :webmock
end

#
# to record more cassetes, supply service account file
#
path =  File.expand_path(File.dirname(__FILE__) + '/../tmp/service_account.yml')
file = YAML.load_file(path)

GoogleCells.configure do |config|
  config.service_account_email = file['email']
  config.key_file = File.dirname(__FILE__) + file['path']
  config.key_secret = file['key_secret']
end

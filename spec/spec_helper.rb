require 'rspec'
require 'nokogiri'
require 'webmock/rspec'
require 'vcr'

require File.dirname(__FILE__) + '/../lib/google_cells'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :webmock
  c.ignore_request { |req| p req.uri['auth'] }
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

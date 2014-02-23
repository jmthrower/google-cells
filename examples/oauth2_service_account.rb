require 'rubygems'
require 'sinatra'
require "google_cells"
require 'yaml'

path =  File.expand_path(File.dirname(__FILE__) + '/../tmp/service_account.yml')
file = YAML.load_file(path)

GoogleCells.configure do |config|
  config.service_account_email = file['email']
  config.key_file = File.dirname(__FILE__) + file['path']
  config.key_secret = file['key_secret']
end
 
require File.expand_path(File.dirname(__FILE__) + '/sinatra/routes')

App::Routes.run!

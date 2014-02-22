require 'rubygems'
require 'sinatra'
require "google_cells"
require 'yaml'

path =  File.expand_path(File.dirname(__FILE__) + '/../tmp/web_flow.yml')
file = YAML.load_file(path)

GoogleCells.configure do |config|
  config.client_id = file['client_id']
  config.client_secret = file['client_secret']
end

module App
  class Routes < ::Sinatra::Base

    enable :sessions

    set :client, GoogleCells.client

    def client
      settings.client
    end

    def authorization
      @authorization ||= (
        auth = client.authorization.dup
        auth.redirect_uri = to('/oauth2_callback')
        auth.update_token!(session)
        auth
      )
    end

    before do
      # Ensure user has authorized the app
      unless authorization.access_token || request.path_info =~ /^\/oauth2/
        redirect to('/oauth2_authorize')
      end
      GoogleCells.client.authorization = authorization
    end

    after do
      # Serialize the access/refresh token to the session
      session[:access_token] = authorization.access_token
      session[:refresh_token] = authorization.refresh_token
      session[:expires_in] = authorization.expires_in
      session[:issued_at] = authorization.issued_at
    end

    get '/oauth2_authorize' do
      # Request authorization
      redirect authorization.authorization_uri.to_s, 303
    end

    get '/oauth2_callback' do
      # Exchange token
      authorization.code = params[:code] if params[:code]
      authorization.fetch_access_token!
      redirect to('/')
    end
  end
end

require File.expand_path(File.dirname(__FILE__) + '/sinatra/routes')

App::Routes.run!

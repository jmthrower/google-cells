require "google_cells/version"
require "google_cells/client"
require "google_cells/spreadsheet"

module GoogleCells
  class << self
    attr_accessor :config
  end

  def self.configure
    self.config ||= Configuration.new
    yield(config)
  end

  class Configuration
    attr_accessor :service_account_email, :key_secret, :key_file

    def initialize
      @key_secret = 'notasecret'

      @api_version = 'v2'
      @cached_api_file = "drive-#{@api_version}.cache"
    end
  end
end

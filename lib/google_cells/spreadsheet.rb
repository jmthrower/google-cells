require 'google_cells/worksheet'
require 'json'

module GoogleCells

  class Spreadsheet < GoogleCells::GoogleObject
    extend UrlHelper
    extend Reader

    @permanent_attributes = [ :title, :updated_at, :author, :key ]
    define_accessors

    class << self

      def list
        spreadsheets = []
        each_entry do |entry|
          args = parse_from_entry(entry)
          spreadsheets << Spreadsheet.new(args)
        end
        spreadsheets
      end

      alias_method :all, :list

      def get(key)
        res = request(:get, worksheets_uri(key))
        args = parse_from_entry(Nokogiri.parse(res.body), key)
        Spreadsheet.new(args)
      end

      def copy(key, opts={})
        params = {}
        if !opts[:writers_can_share].to_s.empty?
          params[:body] = {'writersCanShare' => opts.delete(:writers_can_share)
            }.to_json
          params[:headers] = {'Content-Type' => 'application/json'}
        end
        res = request(:post, copy_uri(key), params)
        s = get(res.data['id'])
      end

      def share(key, params)
        body = {}
        [:role, :type, :value].each do |sym|
          body[sym.to_s] = params.delete(sym)
        end
        params[:body] = body.to_json

        params[:url_params] = {}
        params[:url_params]['sendNotificationEmails'] = params.delete(
          :send_notification_emails) if !params[:send_notification_emails].
          to_s.empty?
        params[:url_params]['emailMessage'] = params.delete(
          :email_message) if params[:email_message]

        params[:headers] = {'Content-Type' => 'application/json'}
        
        res = request(:post, permissions_uri(key), params)
        true
      end
    end

    def share(params)
      self.class.share(self.key, params)
    end

    def copy(opts={})
      self.class.copy(self.key, opts)
    end
    
    def enfold(folder_key)
      return true if @folders && @folders.select{|f| f.key == folder_key}.first
      body = {'id' => self.key}.to_json
      res = self.class.request(:post, self.class.folder_uri(folder_key), 
        :body => body, :headers => {'Content-Type' => 'application/json'})
      @folders << Folder.new(spreadsheet:self, key:folder_key) if @folders
      true
    end

    def folders
      return @folders if @folders
      res = self.class.request(:get, self.class.file_uri(key))
      data = JSON.parse(res.body)
      return @folders = [] if data['parents'].nil?
      @folders = data['parents'].map do |f|
        Folder.new(spreadsheet: self, key:f['id'])
      end
    end

    def worksheets
      return @worksheets if @worksheets
      @worksheets = []
      self.class.each_entry(worksheets_uri) do |entry|
        args = {
          title: entry.css("title").text,
          updated_at: entry.css("updated").text,
          cells_uri: entry.css(
            "link[rel='http://schemas.google.com/spreadsheets/2006#cellsfeed']"
            )[0]["href"],
          lists_uri: entry.css(
            "link[rel='http://schemas.google.com/spreadsheets/2006#listfeed']"
            )[0]["href"],
          row_count: entry.css("gs|rowCount").text.to_i,
          col_count: entry.css("gs|colCount").text.to_i,
          spreadsheet: self
        }
        @worksheets << Worksheet.new(args)
      end
      return @worksheets
    end

    private

    def self.parse_from_entry(entry, key=nil)
      key ||= entry.css("link").select{|el| el['rel'] == 'alternate'}.
        first['href'][/key=.+/][4..-1]
      { title: entry.css("title").first.text,
        key: key,
        updated_at: entry.css("updated").first.text,
        author: Author.new(
          name: entry.css("author/name").first.text,
          email: entry.css("author/email").first.text
        )
      }
    end

    def worksheets_uri; self.class.worksheets_uri(key); end
  end
end

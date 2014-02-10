require 'google_cells/worksheet'
require 'json'

module GoogleCells

  class Spreadsheet < GoogleCells::GoogleObject
    extend Reader

    @permanent_attributes = [ :title, :id, :updated_at, :author, :worksheets_uri,
      :key ]
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

      def get(key)
        spreadsheet = nil
        url = "https://spreadsheets.google.com/feeds/worksheets/#{key}/private/full"
        each_entry do |entry|
          args = parse_from_entry(entry)
          spreadsheet = Spreadsheet.new(args.merge(key:key))
          break
        end
        spreadsheet
      end

      def copy(key, opts={})
        url = "https://www.googleapis.com/drive/v2/files/#{key}/copy"
        params = {}
        if params[:folder_key]
          params[:body] = {
            'parents' => [
            opts[:folder_key]
          ]}.to_json,
          params[:headers] = {'Content-Type' => 'application/json'}
        end
        res = request(:post, url, params)
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
        url = "https://www.googleapis.com/drive/v2/files/#{key}/permissions"
        res = request(:post, url, params)
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
      uri = "https://www.googleapis.com/drive/v2/files/#{folder_key}/children"
      body = {'id' => self.key}.to_json
      res = self.class.request(:post, uri, :body => body, :headers => 
        {'Content-Type' => 'application/json'})
      @folders << Folder.new(spreadsheet:self, key:folder_key) if @folders
      true
    end

    def folders
      return @folders if @folders
      # for metadata/folder info, need google drive api record
      uri = "https://www.googleapis.com/drive/v2/files/#{self.key}"
      res = self.class.request(:get, uri)
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

    def self.parse_from_entry(entry)
      key = entry.css("link").select{|el| el['rel'] == 'alternate'}.
        first['href'][/key=.+/][4..-1]
      { title: entry.css("title").text,
        id: entry.css("id").text,
        key: key,
        updated_at: entry.css("updated").text,
        author: Author.new(
          name: entry.css("author/name").text,
          email: entry.css("author/email").text
        ),
        worksheets_uri: entry.css("link[rel='http://schemas.google.com/spreadsheets" + 
          "/2006#worksheetsfeed']")[0]["href"]
      }
    end
  end
end

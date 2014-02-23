require 'sinatra/base'

module App
  class Routes < ::Sinatra::Base
    get '/' do
      @spreadsheets = GoogleCells::Spreadsheet.list
      @spreadsheets.sort_by!{|s| s.updated_at}
      @spreadsheets.reverse!
      text = "<h1>All Spreadsheets</h1>"
      if @spreadsheets.empty?
        text << "Nothing here."
      else
        text << "<% for s in @spreadsheets %>"
        text << "<br/><%= s.updated_at %> -- <a href=\"https://docs.google.com/"
        text << "spreadsheet/ccc?key=<%= s.key %>\"><%= s.title %></a>"
        text << "<% end %>"
      end
      erb text
    end
  end
end

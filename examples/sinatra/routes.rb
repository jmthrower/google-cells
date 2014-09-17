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
        @spreadsheets.each do |s|
          text << "<br/>#{s.updated_at} --"
          text << "<a href=\"/spreadsheets/#{s.key}\">#{s.title}</a>"
        end
      end
      erb text
    end

    get '/spreadsheets/:spreadsheet_id' do
      _load_spreadsheet
      @spreadsheet = GoogleCells::Spreadsheet.get(params[:spreadsheet_id])
      text = "<h1>Spreadsheet: #{@spreadsheet.title}</h1>"
      worksheets = @spreadsheet.worksheets
      worksheets.each_with_index do |ws, i|
        text << "<b>Worksheet #{i}</b>"
        text << "<br/><a href=\"/spreadsheets/#{@spreadsheet.key}/worksheets/#{i
          }\">#{ws.title}</a>"
        text << "<br/><a href=\"/spreadsheets/#{@spreadsheet.key}/revisions\">"+
          "Revisions</a>"
      end
      erb text
    end

    get "/spreadsheets/:spreadsheet_id/revisions" do
      _load_spreadsheet
      text = "<h1>#{@spreadsheet.title}</h1>"
      @spreadsheet.revisions.each do |r|
        text << "Revision ##{r.id}"
        text << "<ul>"
        text << "<li>Updated: #{r.updated_at}</li>"
        text << "<li>Etag: #{r.etag}</li>"
        text << "<li>Author name: #{r.author.name}</li>"
        text << "<li>Author email: #{r.author.email}</li>"
        text << "</ul>"
      end
      erb text
    end

    get '/spreadsheets/:spreadsheet_id/worksheets/:worksheet_num' do
      _load_spreadsheet
      @worksheet = @spreadsheet.worksheets[params[:worksheet_num].to_i]
      text = "<style>table td{ border-style:solid; border-width:1px;}</style>"
      text << "<h1>#{@spreadsheet.title}</h1>"
      text << "Worksheet #{@worksheet.title} (Showing first 5 rows):"
      text << "<table>"
      @worksheet.rows.from(1).to(5).each do |row|
        text << "<tr><td>"
        text << row.cells.map(&:value).join('</td><td>')
        text << "</td></tr>"
      end
      text << "<form action=\"/spreadsheets/" + params[:spreadsheet_id] + 
        "/worksheets/" + params[:worksheet_num] + "/scramble\" method=\"post\">"
      text << "<button type=\"submit\">Scramble!</button>"
      text << "</form>"
      erb text
    end

    post '/spreadsheets/:spreadsheet_id/worksheets/:worksheet_num/scramble' do
      _load_spreadsheet
      @worksheet = @spreadsheet.worksheets[params[:worksheet_num].to_i]
      cached_array = @worksheet.rows.from(1).to(5).all.dup
      @worksheet.rows.from(1).to(5).each do |row|
        row.cells.each do |c|
          scramble_row = cached_array[rand(cached_array.length)]
          scramble_cell = scramble_row.cells[rand(scramble_row.cells.length)]
          c.input_value = scramble_cell.value
        end
      end
      @worksheet.save!

      path = "/spreadsheets/" + params[:spreadsheet_id] + "/worksheets/" +
        params[:worksheet_num].to_i.to_s
      redirect to(path)
    end

    private

    def _load_spreadsheet
      @spreadsheet = GoogleCells::Spreadsheet.get(params[:spreadsheet_id])
    end
  end
end

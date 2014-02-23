module GoogleCells

  module UrlHelper

    def worksheets_uri(key)
      "https://spreadsheets.google.com/feeds/worksheets/#{key}/private/full"
    end
  end
end

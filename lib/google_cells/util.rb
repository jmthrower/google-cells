module GoogleCells
  module Util

    def e(str)
      CGI.escapeHTML(str.to_s()).gsub(/\n/, '&#x0a;')
    end

    def concat_url(url, piece)
      (url_base, url_query) = url.split(/\?/, 2)
      (piece_base, piece_query) = piece.split(/\?/, 2)
      result_query = [url_query, piece_query].select(){ |s| s && !s.empty? }.join("&")
      return (url_base || "") +
          (piece_base || "") +
          (result_query.empty? ? "" : "?#{result_query}")
    end
  end
end

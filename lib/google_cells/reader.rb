require File.dirname(__FILE__) + '/fetcher'

module GoogleCells

  module Reader
    include GoogleCells::Fetcher

    def each_entry(url=nil, &block)
      doc = raw(url)
      reader = Nokogiri::XML::Reader(doc)
      reader.each do |node|
        next unless node.name == 'entry' && node.node_type == 
          Nokogiri::XML::Reader::TYPE_ELEMENT
        block.call(Nokogiri.parse(node.outer_xml))
      end
    end
  end
end


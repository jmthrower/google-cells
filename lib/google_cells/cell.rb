module GoogleCells
  class Cell < GoogleCells::GoogleObject
    include Util

    @permanent_attributes = [:title, :id, :value, :numeric_value, :row, :col, 
      :edit_url, :worksheet]
    define_accessors

    attr_reader :input_value

    def input_value=(v)
      @input_value = v
      worksheet.track_changes(self)
      v
    end

    def to_xml
<<-EOS
    <entry>
      <batch:id>#{e(row)},#{e(col)}</batch:id>
      <batch:operation type="update"/>
      <id>#{e(id)}</id>
      <link rel="edit" type="application/atom+xml"
        href="#{e(edit_url)}"/>
      <gs:cell row="#{e(row)}" col="#{e(col)}" inputValue="#{e(input_value)}"/>
    </entry>
EOS
    end
  end
end



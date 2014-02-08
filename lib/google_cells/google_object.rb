 module GoogleCells

  class GoogleObject
    class << self
      attr_reader :permanent_attributes

      def define_accessors
        self.instance_eval do
          @permanent_attributes.each do |k|
            define_method(k){ @values[k] }
          end
        end
      end
    end

    def initialize(attribs={})
      @values = {}
      self.class.permanent_attributes.each{|a| @values[a] = attribs[a]}

      extra = attribs.keys - self.class.permanent_attributes
      extra.each do |a|
        if self.respond_to?("#{a}=")
          instance_variable_set("@#{a}".to_sym, attribs[a])
          next
        end
        raise ArgumentError, "invalid attribute #{a} passed to #{
          self.class}"
      end
    end
  end
end

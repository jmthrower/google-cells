 module GoogleCells

  class GoogleObject
    class << self
      attr_reader :permanent_attributes

      def define_accessors
        self.instance_eval do
          @permanent_attributes.each do |k|
            k_eq = :"#{k}="
            define_method(k){ @values[k] }
            define_method(k_eq){ |v| @values[k] = v }
          end
        end
      end
    end

    def initialize(attribs={})
      @values = {}
      self.class.permanent_attributes.each{|a| @values[a] = attribs[a]}

      extra = attribs.keys - self.class.permanent_attributes
      if !extra.empty?
        raise ArgumentError, "invalid attribute #{extra.join(', ')} passed to #{
          self.class}"
      end
    end
  end
end

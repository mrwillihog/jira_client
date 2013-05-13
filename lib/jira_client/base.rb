require "jira_client/core_ext/string"

module JiraClient
  class Base
    class << self
      # Initialize class variable if not set
      def conversions
        @conversions ||= {}
      end

      def convert(attribute, conversion)
        if conversion.instance_of? Proc
          conversions[attribute] = conversion
        elsif conversion < JiraClient::Base
          conversions[attribute] = lambda {|v| conversion.from_response(v)}
        end
      end

      def attr_reader(*attrs)
        mod = Module.new do
          attrs.each do |attribute|
            define_method attribute do
              @attrs[attribute.to_sym]
            end
            define_method "#{attribute}?" do
              !!@attrs[attribute.to_sym]
            end
          end
        end
        include mod
      end

      def from_response(attrs={})
        return unless attrs
        new(attrs)
      end

    end

    def initialize(attrs={})
      self.class.conversions.each do |key, value|
        if attrs.has_key? key
          if attrs[key].kind_of? Array
            attrs[key] = attrs[key].map {|elem| value.call(elem)}
          else
            attrs[key] = value.call(attrs[key])
          end
        end
      end
      @attrs = attrs
    end

  end
end
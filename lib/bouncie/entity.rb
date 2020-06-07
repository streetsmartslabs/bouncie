require 'active_support/inflector'

module Bouncie
  class Entity
    def initialize(data)
      @data = data.transform_keys { |k| k.underscore.to_sym }
      @data.each do |key, val|
        if val.is_a?(Hash)
          @data[key] = Bouncie::Entity.new(val)
        elsif val.is_a?(Array)
          @data[key] = val.map { |v| Bouncie::Entity.new(v) }
        elsif val.is_a?(String) && val.to_s.ends_with?('_at') || val.to_s.ends_with?('_time')
          @data[key] = DateTime.parse(val)
        end
      end
    end

    def method_missing(method_name, *args, &block)
      if @data.key?(method_name)
        @data[method_name]
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      @data.key?(method_name)
    end
  end
end

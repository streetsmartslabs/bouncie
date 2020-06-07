# frozen_string_literal: true

require 'active_support/inflector'

module Bouncie
  # Abstract base class for objects returned from API requests. Parses dates, converts keys to underscore.
  class Entity
    def initialize(data)
      @data = data.transform_keys { |k| k.to_s.underscore.to_sym }
      massage_data
    end

    def method_missing(method_name, *args, &block)
      if @data.key?(method_name)
        @data[method_name]
      else
        super
      end
    end

    def respond_to_missing?(method_name, _include_private = false)
      @data.key?(method_name)
    end

    private

    def massage_data
      @data.each do |key, val|
        if val.is_a?(Hash)
          @data[key] = Bouncie::Entity.new(val)
        elsif val.is_a?(Array)
          @data[key] = val.map { |v| Bouncie::Entity.new(v) }
        elsif val.is_a?(String) && %w[_updated _time timestamp].any? { |v| key.to_s.end_with?(v) }
          @data[key] = DateTime.parse(val)
        end
      end
    end
  end
end

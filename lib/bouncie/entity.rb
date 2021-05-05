# frozen_string_literal: true

require 'active_support/inflector'

module Bouncie
  # Abstract base class for objects returned from API requests. Parses dates, converts keys to underscore.
  class Entity
    def initialize(data)
      transformed = data.transform_keys { |k| k.to_s.underscore.to_sym }
      @data = massage_data(transformed)
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

    def massage_data(input)
      input.each_with_object({}) do |(key, val), memo|
        memo[key] = massage_value(val)
      end
    end

    def massage_value(value)
      if value.is_a?(Hash)
        Bouncie::Entity.new(value)
      elsif value.is_a?(Array)
        value.map { |v| massage_value(v) }
      elsif value.is_a?(String) && value.match?(/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}(?:\.\d*)?)((-(\d{2}):(\d{2})|Z)?)$/)
        DateTime.parse(value)
      else
        value
      end
    end
  end
end

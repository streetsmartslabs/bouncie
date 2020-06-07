# frozen_string_literal: true

require 'faraday'
require 'oj'

module Bouncie
  # Class that wraps a Faraday connection in order to interact with the Bouncie API
  class Client
    API_ENDPOINT = 'https://api.bouncie.dev/v1'

    attr_reader :options

    # @param [Hash] options the options to create a `Bouncie::Client` with.
    # @option opts [String] :api_key your Bouncie app's API key. Retrieve this from https://www.bouncie.dev/apps. Required.
    # @option opts [String] :authorization_code code from a user who grants access to their information via OAuth. Required.
    # @option opts [Hash] :headers hash of any additional headers to add to HTTP requests
    def initialize(options)
      @options = options
    end

    # @param imei [String] (Required) IMEI for the vehicle to retrieve trips for
    # @param transaction_id [String] Unique Trip Identifier
    # @param gps_format [String] (Required) One of: `polyline` or `geojson`
    # @param starts_after: [ISODate] Will match trips with a starting time after this parameter. The window between starts-after and ends-before must be no longer than a week. If not provided, the last week will be used by default
    # @param ends_before: [ISODate] Will match trips with an ending time before this parameter
    # @return [Trip]
    def trips(imei:, transaction_id: nil, gps_format: 'polyline', starts_after: nil, ends_before: nil)
      request(
        http_method: :get,
        endpoint: 'trips',
        params: {
          imei: imei,
          transaction_id: transaction_id,
          gps_format: gps_format,
          starts_after: starts_after,
          ends_before: ends_before
        }.compact
      ).map { |data| Bouncie::Trip.new(data) }
    end

    # @param vin [String] (optional) Vehicles with vin matching given value
    # @param imei [String] (optional) Vehicles with imei matching given value
    # @return [Vehicle]
    def vehicles(imei: nil, vin: nil)
      request(
        http_method: :get,
        endpoint: 'vehicles',
        params: {
          imei: imei,
          vin: vin
        }.compact
      ).map { |data| Bouncie::Vehicle.new(data) }
    end

    private

    def headers
      @headers ||= {
        'AuthorizationCode' => options[:authorization_code],
        'ApiKey' => options[:api_key]
      }.merge(options[:headers] || {})
    end

    def client
      @client ||= Faraday.new(API_ENDPOINT, headers: headers) do |client|
        client.request :url_encoded
        client.adapter Faraday.default_adapter
      end
    end

    def request(http_method:, endpoint:, params: {})
      params.transform_keys! { |k| k.to_s.dasherize }
      resp = client.public_send(http_method, endpoint, params)
      Oj.load(resp.body)
    end
  end
end

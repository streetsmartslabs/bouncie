require 'faraday'
require 'oj'

module Bouncie
  class Client
    API_ENDPOINT = 'https://api.bouncie.dev/v1'.freeze

    attr_reader :options

    def initialize(options)
      @options = options
    end

    def trips(imei:, transaction_id: nil, gps_format: 'polyline', starts_after: nil, ends_before: nil)
      request(
        http_method: :get,
        endpoint:    'trips',
        params: {
          imei:           imei,
          transaction_id: transaction_id,
          gps_format:     gps_format,
          starts_after:   starts_after,
          ends_before:    ends_before
        }.compact
      ).map { |data| Bouncie::Trip.new(data) }
    end

    def vehicles(imei: nil, vin: nil)
      request(
        http_method: :get,
        endpoint: 'vehicles',
        params: {
          imei: imei,
          vin:  vin
        }.compact
      ).map { |data| Bouncie::Vehicle.new(data) }
    end

    private

    def headers
      @_headers ||= {
        'AuthorizationCode' => options[:authorization_code],
        'ApiKey'            => options[:api_key],
      }.merge(options[:headers] || {})
    end

    def client
      @_client ||= Faraday.new(API_ENDPOINT, headers: headers) do |client|
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

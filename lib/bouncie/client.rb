# frozen_string_literal: true

require 'faraday'
require 'json'

module Bouncie
  # Class that wraps a Faraday connection in order to interact with the Bouncie API
  class Client
    API_ENDPOINT = 'https://api.bouncie.dev/v1'

    attr_reader :options

    # @param [Hash] options the options to create a `Bouncie::Client` with.
    # @option opts [String] :client_id your Bouncie app's client_id. Retrieve this from https://www.bouncie.dev/apps. Required.
    # @option opts [String] :client_id your Bouncie app's client_secret. Retrieve this from https://www.bouncie.dev/apps. Required.
    # @option opts [String] :redirect_uri the same redirect uri used to retrieve the token initially. Used for verification only. Required.
    # @option opts [String] :authorization_code code from a user who grants access to their information via OAuth. Required.
    # @option opts [String] :access_token token from a user who grants access to their information via OAuth. Required.
    # @option opts [Hash] :headers hash of any additional headers to add to HTTP requests
    def initialize(options)
      @options = options
    end

    # @param imei [String] (Required) IMEI for the vehicle to retrieve trips for
    # @param transaction_id [String] Unique Trip Identifier
    # @param gps_format [String] (Required) One of: `polyline` or `geojson`
    # @param starts_after [ISODate] Will match trips with a starting time after this parameter. The window between starts-after and ends-before must be no longer than a week. If not provided, the last week will be used by default
    # @param ends_before [ISODate] Will match trips with an ending time before this parameter
    # @return [Trip]
    def trips(imei:, transaction_id: nil, gps_format: 'polyline', starts_after: nil, ends_before: nil)
      request(
        http_method: :get,
        endpoint: 'trips',
        params: {
          imei: imei,
          transactionId: transaction_id,
          gpsFormat: gps_format,
          startsAfter: starts_after,
          endsBefore: ends_before
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

    # @return [User]
    def user
      data = request(
        http_method: :get,
        endpoint: 'user'
      )
      Bouncie::User.new(data)
    end

    # rubocop:disable Metrics/AbcSize
    def refresh!
      resp = Faraday.post('https://auth.bouncie.com/oauth/token', {
                            client_id: options[:client_id],
                            client_secret: options[:client_secret],
                            grant_type: 'authorization_code',
                            code: options[:authorization_code],
                            redirect_uri: options[:redirect_uri]
                          })
      if resp.success?
        parsed_resp = JSON.parse(resp.body)
        @headers = headers.merge(Authorization: parsed_resp['access_token'])
        @client = build_client
      end
      resp
    end
    # rubocop:enable Metrics/AbcSize

    private

    def headers
      @headers = { Authorization: options[:access_token] }.merge(options[:headers] || {})
    end

    def client
      @client ||= build_client
    end

    def build_client
      Faraday.new(API_ENDPOINT, headers: headers) do |client|
        client.request :url_encoded
        client.adapter Faraday.default_adapter
      end
    end

    def request(http_method:, endpoint:, params: {})
      params.transform_keys! { |k| k.to_s.dasherize }
      resp = client.public_send(http_method, endpoint, params)
      JSON.parse(resp.body)
    end
  end
end

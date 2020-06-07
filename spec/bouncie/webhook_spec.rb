# frozen_string_literal: true

require 'bouncie'
require 'oj'

module Bouncie
  describe Webhook do
    describe 'parse' do
      shared_examples_for 'a parsable webhook event' do |event_klass, event_type|
        subject(:parsed_event) { Bouncie::Webhook.parse(event_data) }

        let(:event_data) { Oj.load(File.read("spec/fixtures/#{event_type}.json")) }

        it "parses data into a #{event_klass}" do
          expect(parsed_event).to be_an_instance_of(event_klass)
        end
      end

      it_behaves_like 'a parsable webhook event', Bouncie::DeviceEvents::ConnectEvent,          'device_connect_event'
      it_behaves_like 'a parsable webhook event', Bouncie::DeviceEvents::DisconnectEvent,       'device_disconnect_event'
      it_behaves_like 'a parsable webhook event', Bouncie::VehicleHealthEvents::BatteryEvent,   'vehicle_health_battery_event'
      it_behaves_like 'a parsable webhook event', Bouncie::VehicleHealthEvents::MilEvent,       'vehicle_health_mil_event'
      it_behaves_like 'a parsable webhook event', Bouncie::VehicleTripEvents::TripDataEvent,    'vehicle_trip_data_event'
      it_behaves_like 'a parsable webhook event', Bouncie::VehicleTripEvents::TripEndEvent,     'vehicle_trip_end_event'
      it_behaves_like 'a parsable webhook event', Bouncie::VehicleTripEvents::TripMetricsEvent, 'vehicle_trip_metrics_event'
      it_behaves_like 'a parsable webhook event', Bouncie::VehicleTripEvents::TripStartEvent,   'vehicle_trip_start_event'
    end
  end
end

require 'bouncie/device_events/connect_event'
require 'bouncie/device_events/disconnect_event'
require 'bouncie/vehicle_health_events/battery_event'
require 'bouncie/vehicle_health_events/mil_event'
require 'bouncie/vehicle_trip_events/trip_data_event'
require 'bouncie/vehicle_trip_events/trip_end_event'
require 'bouncie/vehicle_trip_events/trip_metrics_event'
require 'bouncie/vehicle_trip_events/trip_start_event'

module Bouncie
  class Webhook
    WEBHOOK_EVENTS_MAP = {
      'connect'      => Bouncie::DeviceEvents::ConnectEvent,
      'disconnect'   => Bouncie::DeviceEvents::DisconnectEvent,
      'battery'      => Bouncie::VehicleHealthEvents::BatteryEvent,
      'mil'          => Bouncie::VehicleHealthEvents::MilEvent,
      'trip_data'    => Bouncie::VehicleTripEvents::TripDataEvent,
      'trip_end'     => Bouncie::VehicleTripEvents::TripEndEvent,
      'trip_metrics' => Bouncie::VehicleTripEvents::TripMetricsEvent,
      'trip_start'   => Bouncie::VehicleTripEvents::TripStartEvent
    }

    def self.parse(data)
      event_name = data[:event_type] || data[:eventType] || data['eventType'] || data['event_type']
      event_klass = Bouncie::Webhook::WEBHOOK_EVENTS_MAP[event_name.underscore]
      event_klass.new(data)
    end
  end
end

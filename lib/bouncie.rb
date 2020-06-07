require 'bouncie/version'
require 'bouncie/client'
require 'bouncie/entity'
require 'bouncie/vehicle'
require 'bouncie/trip'
require 'bouncie/webhook'
require 'bouncie/device_events/connect_event'
require 'bouncie/device_events/disconnect_event'
require 'bouncie/vehicle_health_events/battery_event'
require 'bouncie/vehicle_health_events/mil_event'
require 'bouncie/vehicle_trip_events/trip_data_event'
require 'bouncie/vehicle_trip_events/trip_end_event'
require 'bouncie/vehicle_trip_events/trip_metrics_event'
require 'bouncie/vehicle_trip_events/trip_start_event'

module Bouncie
  class Error < StandardError; end
end

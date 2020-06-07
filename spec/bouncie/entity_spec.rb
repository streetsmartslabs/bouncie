# frozen_string_literal: true

require 'bouncie'

module Bouncie
  describe Entity do
    let(:raw_trip) do
      {
        'transactionId' => '353762078072777-123-1590670937000',
        'hardBrakingCount' => 0,
        'hardAccelerationCount' => 2,
        'distance' => 3.4,
        'gps' => 'qiwaHzkmhVCuBk@pBkAfC~CuB??IXCHUq@???_AkFlA?W????lFuAEU??c@CMp@DbA??CjAQ`@u@X??_A_@c@i@Kk@??',
        'startTime' => '2020-05-28 13:07:07.000Z',
        'endTime' => '2020-05-28 13:17:07.000Z',
        'startOdometer' => 12_011,
        'endOdometer' => 12_014,
        'averageSpeed' => 12,
        'maxSpeed' => 21,
        'fuelConsumed' => 0.2,
        'timeZone' => '-0500'
      }
    end
    let(:raw_vehicle) do
      {
        'model' => {
          'make' => 'GMC',
          'name' => 'Terrain',
          'year' => 2012
        },
        'standardEngine' => '2.4L',
        'vin' => '2GKALMEK8C6225392',
        'imei' => '353762078072777',
        'stats' => {
          'localTimezone' => '-0600',
          'lastUpdated' => '2020-04-28 22:13:17.000Z',
          'location' => '123 Main St, Dallas, Texas 75251, United States',
          'fuelLevel' => 27.3,
          'isRunning' => false,
          'speed' => 0,
          'mil' => {
            'milOn' => false,
            'lastUpdated' => '2020-01-01 12:00:00:000Z'
          },
          'battery' => {
            'status' => 'normal',
            'lastUpdated' => '2020-04-25 12:00:00:000Z'
          }
        }
      }
    end

    context 'when parsing a trip response' do
      let(:entity) { described_class.new(raw_trip) }

      it 'parses dates' do
        expect(entity.start_time).to be_an_instance_of(DateTime)
      end
    end

    context 'when parsing a vehicle response' do
      let(:entity) { described_class.new(raw_vehicle) }

      it 'parses nested objects' do
        expect(entity.stats).to be_an_instance_of(described_class)
      end

      it 'parses nested dates' do
        expect(entity.stats.last_updated).to be_an_instance_of(DateTime)
      end
    end
  end
end

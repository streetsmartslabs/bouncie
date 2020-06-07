# frozen_string_literal: true

require 'bouncie'

module Bouncie
  describe Client do
    let(:options) { {} }
    let(:client) { described_class.new(options) }

    let(:conn) do
      Faraday.new do |builder|
        builder.adapter :test do |stub|
          stub.get('/vehicles') do |_env|
            [
              200,
              { 'Content-Type': 'application/json' },
              '[
                {
                  "model": {
                    "make": "GMC",
                    "name": "Terrain",
                    "year": 2012
                    },
                  "standardEngine": "2.4L",
                  "vin": "2GKALMEK8C6225392",
                  "imei": "353762078072777",
                  "stats": {
                    "localTimezone": "-0600",
                    "lastUpdated": "2020-04-28 22:13:17.000Z",
                    "location": "123 Main St, Dallas, Texas 75251, United States",
                    "fuelLevel": 27.3,
                    "isRunning": false,
                    "speed": 0,
                    "mil": {
                      "milOn": false,
                      "lastUpdated": "2020-01-01 12:00:00:000Z"
                    },
                    "battery": {
                      "status": "normal",
                      "lastUpdated": "2020-04-25 12:00:00:000Z"
                    }
                  }
                }
              ]'
            ]
          end
          stub.get('/trips?imei=353762078072777') do |_env|
            [
              200,
              { 'Content-Type': 'application/json' },
              '[
                {
                  "transactionId": "353762078072777-123-1590670937000",
                  "hardBrakingCount": 0,
                  "hardAccelerationCount": 2,
                  "distance": 3.4,
                  "gps": "qiwaHzkmhVCuBk@pBkAfC~CuB??IXCHUq@???_AkFlA?W????lFuAEU??c@CMp@DbA??CjAQ`@u@X??_A_@c@i@Kk@??",
                  "startTime": "2020-05-28 13:07:07.000Z",
                  "endTime": "2020-05-28 13:17:07.000Z",
                  "startOdometer": 12011,
                  "endOdometer": 12014,
                  "averageSpeed": 12,
                  "maxSpeed": 21,
                  "fuelConsumed": 0.2,
                  "timeZone": "-0500"
                }
              ]'
            ]
          end
        end
      end
    end

    before do
      allow(client).to receive(:client).and_return(conn)
    end

    it 'can be instantiated' do
      expect(client).to be_an_instance_of(described_class)
    end

    describe '#vehicles' do
      subject(:vehicles) { client.vehicles }

      it 'retrieves an array of vehicles' do
        expect(vehicles).to be_an_instance_of(Array)
        expect(vehicles.first).to be_an_instance_of(Bouncie::Vehicle)
      end
    end

    describe '#trips' do
      subject(:trips) { client.trips(imei: 353_762_078_072_777) }

      it 'retrieves an array of trips' do
        expect(trips).to be_an_instance_of(Array)
        expect(trips.first).to be_an_instance_of(Bouncie::Trip)
      end
    end
  end
end

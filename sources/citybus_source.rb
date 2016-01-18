require 'httparty'

# A sourcing interface for CityBus' "public" API. Given a datatype, this Source
# can apply every field from that table onto your models.
class CityBusSource < SourcedAttributes::Source
  register_source :citybus

  # The top-level domain and path to the root of the DoubleMap API. Full paths
  # are made by prepending an agency name and appending an endpoint (from the
  # @@endpoints Hash below).
  @@api_root = 'http://bus.gocitybus.com/Public/map.aspx'

  # CityBus is being weird and doesn't use the same Route IDs between it's API
  # and it's GTFS dump, so this map is a temporary fix.
  ROUTE_MAP = {
    '6a638a2a-b564-4a21-9716-4da51b128e5e': '12', # Gold Loop
    '0e39e6ab-dbca-4815-b9ff-13e408e3d3c0': '13', # Silver Loop
    '52bbe9d2-b4cf-43cd-b89f-368deae90a60': '14', # Black Loop
    '8dcf1b23-8fbb-4400-ac7b-74a161c2cb65': '15', # Tower Acres
    '91afb8ba-d2ab-416c-87ce-8dca2c61b6eb': '16', # Bronze Loop
    '33bf2e3b-9db1-465e-9e1a-222370f8a070': '17', # Ross Ade
    '39ad4000-801d-4733-a489-7526b41d0504': '18', # Nightrider
    'd8b5d5f6-d0f6-49dc-800d-2e7d355f98b4': '19', # Inner Loop
    '6df03e74-551e-4024-bd48-e88e4d4cb9d4': '1A', # Market Square
    'ec55568d-a519-4619-a57b-378a4cb69324': '1B', # Salisbury
    '5213ac6c-21e7-4de4-8d40-0107c9c0cdc7': '20', # AvTech
    '55a573e2-f087-4887-b85c-a58fe2aeb0cd': '21', # The Avenue
    '58c2d35a-737c-430f-951c-a74f8320246a': '23', # Connector
    'dababfbf-561d-4df9-a168-4070c7fe3e1a': '27', # Outer Loop
    '7a0ad873-f683-4a38-aba1-208dbd55fbe3': '2A', # Schuyler Ave
    '3ab636c6-3656-4686-9057-e2fb0255f608': '2B', # Union St
    'e8476eca-d1ad-407b-9b19-2d92ca2abe38': '3',  # Lafayette Square
    '6aa2cfa3-a304-4c54-b3d9-ebe273446e61': '4A', # Tippecanoe Mall
    'daaec0b1-f4c0-463e-b4e1-4d1afad6f5e5': '4B', # Purdue West
    '5bc66522-9fce-482c-aa2a-e6f82fa684fe': '5A', # Happy Hollow
    '3a7d3b6d-9dc5-48fa-a868-5bce6576f4b8': '5B', # Northwestern
    'd8002ae1-45be-4790-b495-266b6b67998b': '6A', # Fourth St
    '15fa2331-0dc6-4220-b272-280a31579600': '6B', # South 9th St
    'c2c0d517-1fb7-4fde-b165-7adee3ed2c7e': '7',  # South St
    'a82aabf8-202b-4494-aca8-01470fa8b257': '8',  # WB/Klondike Express
  }

  # A map of endpoints to (somewhat) friendlier names for use in the
  # configuration DSL.
  @@endpoints = {
    vehicles:     '/GetVehicles',
    vehicle_info: '/GetVehicleInfo'
  }


  def refresh
    # CityBus puts the JSON response in a string (why?) under the key 'd'.
    citybus_data = vehicle_list
    # Map the data into the @source_data object.
    @source_data = citybus_data.map do |record|
      record.merge! vehicle_info_for(record['VehicleId'])
      symbolized_record = Hash[record.map{ |(k,v)| [k.to_s.underscore.to_sym,v] }]
      symbolized_record[:id]          = symbolized_record.delete(:vehicle_id)
      symbolized_record[:code]        = symbolized_record.delete(:vehicle_info)
      next_stop = symbolized_record.delete(:stop_list)[0]
      if next_stop
        symbolized_record[:next_stop]   = next_stop['StopCode']
        symbolized_record[:arriving_at] = Time.parse(next_stop['DepartureTime'])
      end
      symbolized_record
    end
  end

  def vehicle_list
    url = "#{@@api_root}/GetVehicles"
    response = HTTParty.post(url,
      body: {
        'routeIdList': ROUTE_MAP.keys
      }.to_json,
      headers: {
        'Content-Type' => 'application/json; charset=utf-8'
      }
    )
    JSON.parse(response['d'])
  end

  def vehicle_info_for vehicle_id
    info_url = "#{@@api_root}/GetVehicleInfo"
    response = HTTParty.post(info_url,
      body: {
        'vehicleId': vehicle_id
      }.to_json,
      headers: {
        'Content-Type' => 'application/json; charset=utf-8'
      }
    )
    JSON.parse(response['d'])
  end
end

require 'spec_helper'

RSpec.describe Facility do
  before(:each) do
    @facility = Facility.new({name: 'DMV Tremont Branch', address: '2855 Tremont Place Suite 118 Denver CO 80205', phone: '(720) 865-4600'})
    @facility_2 = Facility.new({name: 'DMV Northeast Branch', address: '4685 Peoria Street Suite 101 Denver CO 80239', phone: '(720) 865-4600'})
    @cruz = Vehicle.new({vin: '123456789abcdefgh', year: 2012, make: 'Chevrolet', model: 'Cruz', engine: :ice} )
    @camaro = Vehicle.new({vin: '1a2b3c4d5e6f', year: 1969, make: 'Chevrolet', model: 'Camaro', engine: :ice} )
    @bolt = Vehicle.new({vin: '987654321abcdefgh', year: 2019, make: 'Chevrolet', model: 'Bolt', engine: :ev} )
    @registrant_1 = Registrant.new('Bruce', 18, true)
    @registrant_2 = Registrant.new('Penny', 16)
    @registrant_3 = Registrant.new('Tucker', 15 )
  end

  describe '#initialize' do
    it 'can initialize' do
      expect(@facility).to be_an_instance_of(Facility)
      expect(@facility.name).to eq('DMV Tremont Branch')
      expect(@facility.address).to eq('2855 Tremont Place Suite 118 Denver CO 80205')
      expect(@facility.phone).to eq('(720) 865-4600')
      expect(@facility.services).to eq([])
    end
  end

  describe '#add service' do
    it 'can add available services' do
      expect(@facility.services).to eq([])

      @facility.add_service('New Drivers License')
      @facility.add_service('Renew Drivers License')
      @facility.add_service('Vehicle Registration')
      
      expect(@facility.services).to eq(['New Drivers License', 'Renew Drivers License', 'Vehicle Registration'])
    end
  end

  describe '#register_vehicle' do
    it 'can register a vehicle' do
      @facility.add_service('Vehicle Registration')
      expect(@facility.registered_vehicles).to eq([])

      @facility.register_vehicle(@cruz)
      expect(@facility.registered_vehicles.count).to eq(1)
    end

    it 'can add a registration date to a vehicle' do
      @facility.add_service('Vehicle Registration')
      @facility.register_vehicle(@cruz)
      expect(@cruz.registration_date).to be_an_instance_of(Date)
    end

    it 'does not register a vehicle if the service is not listed' do
      facility_2 = Facility.new({name: 'DMV Northeast Branch', address: '4685 Peoria Street Suite 101 Denver CO 80239', phone: '(720) 865-4600'})
      bolt = Vehicle.new({vin: '987654321abcdefgh', year: 2019, make: 'Chevrolet', model: 'Bolt', engine: :ev} )

      expect(facility_2.services).to eq([])
      expect(facility_2.register_vehicle(@bolt)).to eq(nil)
    end

    it 'changes the cost to register a vehicle depending on age' do
      @facility.add_service('Vehicle Registration')
      expect(@facility.collected_fees).to eq(0)
  
      @facility.register_vehicle(@cruz)
      expect(@facility.collected_fees).to eq(100)
      @facility.register_vehicle(@camaro)
      expect(@facility.collected_fees).to eq(125)
      @facility.register_vehicle(@bolt)
      expect(@facility.collected_fees).to eq(325)
      end
  end

  describe '#administer_written_test' do
    it 'can tell if a facility offers the service or not' do
      expect(@facility.administer_written_test(@registrant_1)).to eq(false)
      @facility.add_service('Written Test')
      expect(@facility.administer_written_test(@registrant_1)).to eq(true)
    end

    it 'can administer a written test if the facility offers the service' do
      @facility.add_service('Written Test')
      @facility.administer_written_test(@registrant_1)

      expect(@registrant_1.license_data).to eq({:written=>true, :license=>false, :renewed=>false})
    end

    it 'can check if the registrant has a permit or not' do
      @facility.add_service('Written Test')

      expect(@registrant_2.permit?).to eq(false)
      expect(@facility.administer_written_test(@registrant_2)).to eq(false)

      @registrant_2.earn_permit
      @facility.add_service('Written Test')

      expect(@facility.administer_written_test(@registrant_2)).to eq(true)
    end
  end

  describe '#administer_road_test' do
    it 'can tell if a facility offers the service or not' do
      expect(@facility.administer_road_test(@registrant_1)).to eq(false)
    end

    it 'can check if the registrant took the written test or not' do
      @facility.add_service('Road Test')

      expect(@registrant_2.license_data[:written]).to eq(false)
      expect(@facility.administer_road_test(@registrant_2)).to eq(false)

      @facility.add_service('Written Test')
      @registrant_2.earn_permit
      @facility.administer_written_test(@registrant_2)

      expect(@registrant_2.license_data[:written]).to eq(true)
      expect(@facility.administer_road_test(@registrant_2)).to eq(true)
      expect(@registrant_2.license_data[:license]).to eq(true)
    end
  end

  describe '#renew_drivers_license' do
    it 'can check if the facility offers the service' do
      expect(@facility.renew_drivers_license(@registrant_1)).to eq(false)
    end

    it 'can renew the registrants license if they have one' do
      @facility.add_service('Written Test')
      @facility.add_service('Road Test')
      @facility.add_service('Rewnew License')
      @facility.administer_written_test(@registrant_1)

      expect(@facility.renew_drivers_license(@registrant_1)).to eq(false)

      @facility.administer_road_test(@registrant_1)
      
      expect(@facility.renew_drivers_license(@registrant_1)).to eq(true)
      expect(@registrant_1.license_data[:renew]).to eq(true)
    end
  end

  describe '@hours attribute' do
    it 'tracks the hours of facilities' do
      @facility = Facility.new({name: 'DMV Tremont Branch', address: '2855 Tremont Place Suite 118 Denver CO 80205', phone: '(720) 865-4600', hours: 'M-F: 7:30 AM until 5:00 PM'})
      @facility_2 = Facility.new({name: 'DMV Northeast Branch', address: '4685 Peoria Street Suite 101 Denver CO 80239', phone: '(720) 865-4600'})

      expect(@facility.hours).to eq('M-F: 7:30 AM until 5:00 PM')
      expect(@facility_2.holidays_closed).to eq(nil)
    end
  end

  describe '@holidays_closed attribute' do
    it 'shows the holidays closed if a hash has it included' do
      @facility = Facility.new({name: 'DMV Tremont Branch', address: '2855 Tremont Place Suite 118 Denver CO 80205', phone: '(720) 865-4600', hours: 'M-F: 7:30 AM until 5:00 PM', holidays_closed: 'Christmas and New Years'})
      @facility_2 = Facility.new({name: 'DMV Northeast Branch', address: '4685 Peoria Street Suite 101 Denver CO 80239', phone: '(720) 865-4600'})

      expect(@facility.holidays_closed).to eq('Christmas and New Years')
      expect(@facility_2.holidays_closed).to eq(nil)
    end
  end

  describe '#collect_fees' do
    it 'checks the plate type of a car and collects fees accordingly' do
      @facility.add_service('Vehicle Registration')
      @facility_2.add_service('Vehicle Registration')

      expect(@facility.collect_fees(@cruz)).to eq(100)
      expect(@facility.collect_fees(@bolt)).to eq(300)
      expect(@facility.collect_fees(@camaro)).to eq(325)
      expect(@facility_2.collect_fees(@bolt)).to eq(200)
    end
  end
end

require 'spec_helper'

RSpec.describe VehicleFactory do
  before(:each) do
    @factory = VehicleFactory.new
  end

  describe '#initialize' do
    it 'can initialize' do
      expect(@factory).to be_an_instance_of(VehicleFactory)
    end
  end

  describe '#create_vehicles' do
    it 'can create vehicles with an API' do
      wa_ev_registrations = DmvDataService.new.wa_ev_registrations
      @factory.create_vehicles(wa_ev_registrations)

      expect(@factory.vehicles).to include(Vehicle)
      expect(@factory.vehicles.length).to be > 100

        @factory.vehicles.each do |car|
          expect(car).to be_an_instance_of(Vehicle)
          expect(car.vin.nil?).to eq(false)
          expect(car.year.nil?).to eq(false)
          expect(car.make.nil?).to eq(false)
          expect(car.model.nil?).to eq(false)
          expect(car.engine.nil?).to eq(false)
        end
      end
    end

  describe '#make_and_models' do
    it 'can make a hash of make and models with the list of vehicles created' do
      wa_ev_registrations = DmvDataService.new.wa_ev_registrations
      @factory.create_vehicles(wa_ev_registrations)

      expect(@factory.make_and_models).to be_an_instance_of(Hash)
      expect(@factory.make_and_models.keys.include?("TESLA")).to be(true)
      expect(@factory.make_and_models.keys.include?("NISSAN")).to be(true)
      expect(@factory.make_and_models.keys.include?("TOYOTA")).to be(true)
      expect(@factory.make_and_models.values).to be_an_instance_of(Array)
    end
  end

  describe 'EV Registrations - #most_popular_ev' do
    it 'can iterate through the list and find the most popular make/model' do
      wa_ev_registrations = DmvDataService.new.wa_ev_registrations
      @factory.create_vehicles(wa_ev_registrations)
      @factory.most_popular_ev

      expect(@factory.most_popular_ev).to eq("The most popular make and model is the NISSAN Leaf!")
    end
  end

  describe 'EV Registrations - #registered_evs_for_model_year' do
    it 'can count the number of registered evs for a model year' do
      wa_ev_registrations = DmvDataService.new.wa_ev_registrations
      @factory.create_vehicles(wa_ev_registrations)

      expect(@factory.registered_evs_for_model_year("2013")).to eq(107)
      expect(@factory.registered_evs_for_model_year(2013)).to eq("Error, try a string")
      expect(@factory.registered_evs_for_model_year("12")).to eq("Year must be 4 characters long")
      expect(@factory.registered_evs_for_model_year("2025")).to eq("Year is too early for EVs or in the future")
    end
  end

  describe '#county_with_most_registered_vehicles' do
    it 'can list the county with the most registered vehicles' do
      wa_ev_registrations = DmvDataService.new.wa_ev_registrations
      @factory.create_vehicles(wa_ev_registrations)

      expect(@factory.county_with_most_registered_vehicles).to eq("King")

      ny_registrations = DmvDataService.new.ny_registrations
      ny_factory = VehicleFactory.new
      ny_factory.create_vehicles(ny_registrations)
      expect(ny_factory.county_with_most_registered_vehicles).to eq("SUFFOLK")
    end
  end

  describe 'second data source from NY' do
    it 'can #create_vehicles with NY API' do
      ny_registrations = DmvDataService.new.ny_registrations
      @factory.create_vehicles(ny_registrations)

      expect(@factory.vehicles.length).to be > 100

      @factory.vehicles.each do |car|
        expect(car).to be_an_instance_of(Vehicle)
        expect(car.vin.nil?).to eq(false)
        expect(car.year.nil?).to eq(false)
        expect(car.make.nil?).to eq(false)
        expect(car.engine.nil?).to eq(false)
        expect(car.model).to eq("Model not listed")
      end
    end 
  end

  describe '#sort_out_boats_and_trl' do
    it 'can sort out data from API to check if it is a motor vehicle or not' do
      ny_registrations = DmvDataService.new.ny_registrations
      ny_registrations.select!{|hash| hash.values.include?("BOAT")}
      expect(ny_registrations.count).to eq(166)

      ny_registrations = DmvDataService.new.ny_registrations
      @factory.sort_out_boats_and_trl(ny_registrations)
      ny_registrations.select!{|hash| hash.values.include?("BOAT")}

      expect(ny_registrations.count).to eq(0)
    end
  end

  describe '#check_for_year' do
    it 'can check the year to make sure that it is a valid date' do
      expect(@factory.check_for_year(1937)).to eq("Error, try a string")
      expect(@factory.check_for_year("1937")).to eq("Year is too early for EVs or in the future")
      expect(@factory.check_for_year("203")).to eq("Year must be 4 characters long")
      expect(@factory.check_for_year("abcd")).to eq("Year is too early for EVs or in the future")
      expect(@factory.check_for_year("abc")).to eq("Year must be 4 characters long")
    end
  end
end
class FacilityLocations
  attr_reader :facilities

  def initialize
    @facilities = []
  end

  def create_facilities(dmv_data)
      dmv_data.each do |facility| 
      hours(dmv_data)
      phone(dmv_data)
      address(dmv_data)
      name(dmv_data)
      holidays_closed(dmv_data)
      facility = Facility.new(facility)
      @facilities << facility
    end
  end
  
  ################Helper Methods#############
  def holidays_closed(dmv_data)
    dmv_data.each do |facility| 
      old_holidaysclosed = facility.keys.select {|key| key.name.include?("holidaysclosed")}[0] 
      # require 'pry'; binding.pry if facility.values.include?("117A NORTH MAIN",) || facility.values.include?("101 WEST 3RD STREET") || facility.values.include?("222")
      if facility.has_key?(:holidays_closed) == false
      facility[:holidays_closed] = facility.delete old_holidaysclosed
      end
      # require 'pry'; binding.pry if facility.keys.include?(:daysopen) && facility[:holidays_closed] == nil
    end
  end

  def name(dmv_data)
    dmv_data.each do |facility| 
      old_name = facility.keys.select {|key| key.name.include?("name") || key.name.include?("office")}[0]
      if facility.has_key?(:name) == false
        facility[:name] = facility.delete old_name
      end
    end
  end

  def address(dmv_data)
    dmv_data.each do |facility|  
      old_address = facility.select {|key,value| key.name.include?("address")}
      old_city = facility.select {|key,value| key.name.include?("city")}
      old_state = facility.select {|key,value| key.name.include?("state")}
      old_zip = facility.select {|key,value| key.name.include?("zip")}
      facility[:address] = [old_address, old_city, old_state, old_zip]
    end
  end

  def phone(dmv_data)
    dmv_data.each do |facility| 
      old_phone = facility.keys.select {|key| key.name.include?("phone")}[0]
      if facility.has_key?(:phone) == false
        facility[:phone] = facility.delete old_phone  
      end
    end
  end

  def hours(dmv_data)
    dmv_data.each do |facility| 
      # Turns :hours => hash
      check_for_multiple_hours(facility)
      # Turns :hours => string
      hours_of_facility(facility)
      # Checks for closed down facilities
      check_for_closed_notice(facility)
    end
  end

# Helper method for finding closed offices
  def check_for_closed_notice(facility)
    if facility[:hours] == nil
      facility.select do |key, value|
        if value != nil && (value.include?("CLOSED UNTIL") || value.include?("closed until"))
          facility[:hours] = value
        end
      end
    end
  end

# Helper method for checking if there are multiple keys for hours
  def check_for_multiple_hours(facility)
    if facility.keys.select {|key| key.name.include?("hour")}.count > 1
    # Create an array of hashes
      hash_of_hours = facility.select {|key,value| key.name.include?("hour")}
      facility.map do |key,value|
        if key.name.include?("hour")
          facility.delete(key)
        end
      end
      facility[:hours] = hash_of_hours
    else
      old_hours = facility.keys.select {|key| key.name.include?("hour")|| key.name.include?("daysopen")}[0]
    end
  end
# Helper method to find the :hours of a facility
  def hours_of_facility(facility)
    if facility.has_key?(:hours) == false
      old_hours = facility.keys.select {|key| key.name.include?("hour")|| key.name.include?("daysopen")}[0]
      facility[:hours] = facility.delete old_hours 
    end
  end

end
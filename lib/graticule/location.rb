module Graticule
  
  # A geographic location
  class Location
    attr_accessor :latitude, :longitude, :street, :locality, :region, :postal_code, :country, :precision, :warning
    alias_method :city, :locality
    alias_method :state, :region
    alias_method :zip, :postal_code
    
    def initialize(attrs = {})
      attrs.each do |key,value|
        instance_variable_set "@#{key}", value
      end
      self.precision ||= :unknown
    end
    
    def attributes
      [:latitude, :longitude, :street, :locality, :region, :postal_code, :country, :precision].inject({}) do |result,attr|
        result[attr] = self.send(attr) unless self.send(attr).blank?
        result
      end
    end
    
    # Returns an Array with latitude and longitude.
    def coordinates
      [latitude, longitude]
    end
    
    def ==(other)
      other.respond_to?(:attributes) ? attributes == other.attributes : false
    end
    
    # Calculate the distance to another location.  See the various Distance formulas
    # for more information
    def distance_to(destination, options = {})
      options = {:formula => :haversine, :units => :miles}.merge(options)
      "Graticule::Distance::#{options[:formula].to_s.titleize}".constantize.distance(self, destination, options[:units])
    end
    
    # Where would I be if I dug through the center of the earth?
    def antipode
      Location.new :latitude => -latitude, :longitude => longitude + (longitude >= 0 ? -180 : 180)
    end
    alias_method :antipodal_location, :antipode
    
    # Returns an address string for this location.
    # Options:
    #  +coordinates+: include latitude/longitude coordinates. defaults to false.
    #  +country+: include the country name. defaults to true.
    #  +postal_code+:
    #  * true => include the postal code 
    #  * false => omit the postal code
    #  * :strict => include postal code if and only if it is properly formed (default)
    #
    #  The :strict postal_code option is a workaround for avoiding incomplete postal code results.
    #  Currently, when geocoding Canadian addresses, Google returns only a 3-character postal code,
    #  e.g. 'MG6', instead of the standard 6-character code. Subsequently Google will fail to
    #  geocode location strings containing these incomplete postal codes. 
    def to_s(options = {})
      options.reverse_merge!({:coordinates => false, :country => true, :postal_code => :strict})      
      result = ""
      result << "#{street}\n" if street
      result << locality_region_and_postal_code(options[:postal_code])
      result << " #{country}" if options[:country] && country
      result << "\nlatitude: #{latitude}, longitude: #{longitude}" if options[:coordinates] && [latitude, longitude].any?
      result
    end
    
    # Returns a string with a locality, region, and postal code.
    #  * true => include the postal code
    #  * false => omit the postal code
    #  * :strict => include the postal code if and only if it is complete and properly formed
    def locality_region_and_postal_code(postal_code_type)
      country_is?(:canada) ?
        locality_region_and_postal_code_ca(postal_code_type) :
        locality_region_and_postal_code_us(postal_code_type)
    end

    COUNTRY_ABBREVIATIONS = { :canada => ['canada', 'ca'], :united_states => ['united states', 'us'] }
     # Tests whether the country attribute matches any of the valid values for the given country symbol.
     # Supported country symbols:
     #   :canada, :united_states
     def country_is?(country_symbol)
       return false if country.blank?
       country_values = COUNTRY_ABBREVIATIONS[country_symbol]
       (country_values && country_values.include?(country.downcase)) ? true : false
     end

     # Returns a string with a locality, region, and US-formatted zip code.
     # Ex. 'New York, NY 10001'
     def locality_region_and_postal_code_us(postal_code_type)
       (postal_code_type == true || postal_code_type == :strict) ?
         [locality, [region, postal_code].compact.join(" ")].compact.join(", ") :
         [locality, region].compact.join(", ")
     end

     # Returns a string with a locality, region, and Canadian-format postal code.
     # Ex. 'Toronto, ON  M6G 3G8'.
     # As per Canada Post there are exactly two spaces between the region and postal code.
     def locality_region_and_postal_code_ca(postal_code_type)
       case postal_code_type
       when :strict
         if postal_code.nil? || (postal_code && (postal_code.size - (postal_code.count ' ')< 6))
           [locality, region].compact.join(", ")
         else
           [locality, [region, postal_code].compact.join("  ")].compact.join(", ")
         end
       when true
         [locality, [region, postal_code].compact.join("  ")].compact.join(", ")
       else
         [locality, region].compact.join(", ")
       end
     end

  end
end
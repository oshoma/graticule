require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

module Graticule
  class LocationPostalCodeTest < Test::Unit::TestCase

    def setup
      @location_ca = Graticule::Location.new(
        :street => "542 College St",
        :locality => "Toronto",
        :region => "ON",
        :postal_code => nil,
        :country => "CA"
      )
    
      @location_us = Graticule::Location.new(
        :street => "1600 Amphitheatre Pkwy",
        :locality => "Mountain View",
        :region => "CA",
        :postal_code => nil, # "94043"
        :country => "US"
      )
    end

    # Canadian address tests
  
    def test_CA_to_s_with_postal_code_option_true_or_blank
      assert_equal "542 College St\nToronto, ON CA", @location_ca.to_s(:postal_code => true)
      assert_equal "542 College St\nToronto, ON CA", @location_ca.to_s
    
      ['M6G 3G8', 'M6G3G8', 'M6G'].each do |test_value|
        @location_ca.postal_code = test_value
        assert_equal "542 College St\nToronto, ON  #{test_value} CA", @location_ca.to_s(:postal_code => true), "Value was #{test_value}"
      end
    end

    def test_CA_to_s_with_postal_code_option_false
      [nil, 'M6G3G8', 'M6G 3G8', 'M6G'].each do |test_value|
        @location_ca.postal_code = test_value
        assert_equal "542 College St\nToronto, ON CA", @location_ca.to_s(:postal_code => false), "Value was #{test_value}"
      end
    end

    def test_CA_to_s_with_postal_code_option_strict
      assert_equal "542 College St\nToronto, ON CA", @location_ca.to_s(:postal_code => :strict)
      assert_equal "542 College St\nToronto, ON CA", @location_ca.to_s
    
      @location_ca.postal_code = 'M6G 3G8'
      assert_equal "542 College St\nToronto, ON  M6G 3G8 CA", @location_ca.to_s(:postal_code => :strict)
    
      @location_ca.postal_code = 'M6G3G8'
      assert_equal "542 College St\nToronto, ON  M6G3G8 CA", @location_ca.to_s(:postal_code => :strict)
     
      @location_ca.postal_code = 'M6G'
      assert_equal "542 College St\nToronto, ON CA", @location_ca.to_s(:postal_code => :strict)
    end
  
  
    ### US address tests
  
    def test_US_to_s_with_postal_code_option_true_or_blank_or_strict
      assert_equal "1600 Amphitheatre Pkwy\nMountain View, CA US", @location_us.to_s(:postal_code => true)
      assert_equal "1600 Amphitheatre Pkwy\nMountain View, CA US", @location_us.to_s
    
      ['94043', '940', '9'].each do |test_value|
        @location_us.postal_code = test_value
        assert_equal "1600 Amphitheatre Pkwy\nMountain View, CA #{test_value} US", @location_us.to_s(:postal_code => true), "Value was #{test_value}"
        assert_equal "1600 Amphitheatre Pkwy\nMountain View, CA #{test_value} US", @location_us.to_s(:postal_code => :strict), "Value was #{test_value}"
        assert_equal "1600 Amphitheatre Pkwy\nMountain View, CA #{test_value} US", @location_us.to_s, "Value was #{test_value}"
      end
    end

    def test_US_to_s_with_postal_code_option_false
      [nil, '94043', '940', '9'].each do |test_value|
        @location_us.postal_code = test_value
        assert_equal "1600 Amphitheatre Pkwy\nMountain View, CA US", @location_us.to_s(:postal_code => false), "Value was #{test_value}"
      end
    end
    
  end

end
  
 
class Location < ActiveRecord::Base
  attr_accessible :admin01, :admin02, :description, :external_feature_id, :historical_name, :latitutde, :link, :location_type, :longitude, :modern_location, :name, :town, :variable_names
end

require 'delayed_indexing'
class Location < ActiveRecord::Base
  include DelayedIndexing
###  attr_accessible :admin01, :admin02, :description, :external_feature_id, :historical_name, :latitutde, :link, :location_type, :longitude, :modern_location, :name, :town, :variable_names
  after_save :after_save
  after_destroy :after_save
end

require 'delayed_indexing'
class Person < ActiveRecord::Base
  include DelayedIndexing
  attr_accessible :name, :alternative_names, :description, :link, :image_link
  after_save :after_save
  before_destroy :before_destroy
end

class Concept < ActiveRecord::Base
  attr_accessible :name, :alternative_names, :description, :link, :image_link
end

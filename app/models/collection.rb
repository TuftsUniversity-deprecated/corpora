class Collection < ActiveRecord::Base
  ###attr_accessible :title
  has_many :corpora_objects, :inverse_of => :collection
end

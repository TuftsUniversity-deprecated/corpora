class MediaType < ActiveRecord::Base
 ### attr_accessible :media_type
  #has_many :corpora_objects, :inverse_of => :corpora_objects
  belongs_to :corpora_object, :inverse_of => :media_type
end

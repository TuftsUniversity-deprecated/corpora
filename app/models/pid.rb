class Pid < ActiveRecord::Base
###  attr_accessible :pid
  #has_one :corpora_objects, :inverse_of => :corpora_objects
  belongs_to :corpora_objects
  validates_presence_of :corpora_objects
end

require 'delayed_indexing'

class CorporaObject < ActiveRecord::Base
  include DelayedIndexing
  mount_uploader :video, VideoUploader
  mount_uploader :transcript, TranscriptUploader
  # don't forget those if you use :attr_accessible (delete method and form caching method are provided by Carrierwave and used by RailsAdmin)
  has_and_belongs_to_many :collections
  belongs_to :media_type, :dependent => :destroy, :inverse_of => :corpora_objects
  validates_uniqueness_of :pid
  #has_one :pid, :dependent => :destroy, :inverse_of => :corpora_objects
  # Since ActiveRecord does not create setters/getters for has_one associations (why is beyond me), diy:
  #   attr_accessible :pid_attributes

  #def pid_id=(id)
  #  self.pid = Pid.find_by_id(id)
  #end
  #
  ###    attr_accessible :corpora_object_id, :pid_attributes, :pid, :pid_id,:title, :video, :media_type, :media_type_id, :published, :video_cache, :remove_video, :collection,:collection_id, :transcript, :transcript_cache, :remove_transcript, :creator, :temporal
  # accepts_nested_attributes_for :media_type, :allow_destroy => true
  # accepts_nested_attributes_for :pid, :allow_destroy => true
  rails_admin do


    list do
      field :pid
      field :title
      field :published
    end
    configure :collections do
      inverse_of :corpora_objects
      # configuration here
    end
  end
  after_save :after_save_reindex_object
  #after_update :after_save_reindex_object
  after_destroy :after_save_reindex_object
end



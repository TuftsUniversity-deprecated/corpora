class CorporaObject < ActiveRecord::Base
    mount_uploader :video, VideoUploader
    mount_uploader :transcript, TranscriptUploader
    # don't forget those if you use :attr_accessible (delete method and form caching method are provided by Carrierwave and used by RailsAdmin)
    belongs_to :collection, :inverse_of => :corpora_objects
    has_one :media_type
    has_one :pid, :dependent => :destroy, :inverse_of => :corpora_objects
    # Since ActiveRecord does not create setters/getters for has_one associations (why is beyond me), diy:
   #   attr_accessible :pid_attributes
   # def pid_id
    #     self.pid.try :pid
   # end
       #def pid_id=(id)
       #  self.pid = Pid.find_by_id(id)
       #end
    #
###    attr_accessible :corpora_object_id, :pid_attributes, :pid, :pid_id,:title, :video, :media_type, :media_type_id, :published, :video_cache, :remove_video, :collection,:collection_id, :transcript, :transcript_cache, :remove_transcript, :creator, :temporal
   # accepts_nested_attributes_for :media_type, :allow_destroy => true
    accepts_nested_attributes_for :pid, :allow_destroy => true

end



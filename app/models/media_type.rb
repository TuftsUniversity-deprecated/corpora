class MediaType < ActiveRecord::Base

  has_many :corpora_objects, :inverse_of => :media_type

  rails_admin do
    object_label_method :media_type
  end
end

class VideoUrl < ActiveRecord::Base
  attr_accessible :pid, :mp4_link, :webm_url, :active
end

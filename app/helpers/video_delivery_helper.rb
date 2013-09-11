module VideoDeliveryHelper

  def self.render_video_path(path, type, pid)
    # no interest in modding the path here but we do want to do it in corpora/sadl
    # so I'm trying to give us a point to override this without bringing the whole
    # controller in to the project
    begin
      video_url = VideoUrl.find_all_by_pid(pid)
    rescue ActiveFedora::ObjectNotFoundError => e
      logger.warn e.message
      return path
    end

    if video_url.empty?
      return path
    else
      video_url = video_url.first
    end

    if video_url.active
      if type == 'mp4'
        path = video_url.mp4_link
      elsif type == 'webm'
        path = video_url.webm_url
      end
    end
    return path
  end
end
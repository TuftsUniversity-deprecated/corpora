class AddWebmUrlToVideoUrls < ActiveRecord::Migration
  def change
    add_column :video_urls, :webm_url, :string
  end
end

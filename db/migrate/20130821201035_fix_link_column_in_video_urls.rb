class FixLinkColumnInVideoUrls < ActiveRecord::Migration
  def up
    rename_column :video_urls, :link, :mp4_link
  end

  def down
    rename_column :video_urls, :mp4_link, :link
  end
end

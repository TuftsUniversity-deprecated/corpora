class CreateVideoUrls < ActiveRecord::Migration
  def up
    create_table :video_urls do |t|
      t.string :pid
      t.string :link
      t.boolean :active
      t.timestamps
    end
  end

  def down
    drop_table :video_urls
  end
end

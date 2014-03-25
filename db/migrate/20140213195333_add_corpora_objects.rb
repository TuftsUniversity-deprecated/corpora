class AddCorporaObjects < ActiveRecord::Migration
  def up
    create_table :corpora_objects do |t|
       t.string :pid
       t.string :title, :null => false
       t.string :video
       t.string :transcript
       t.string :temporal, :null => false
       t.string :creator, :null => false
       t.belongs_to :collection
       t.belongs_to :media_type
       t.boolean :published
       t.boolean :legacy
       t.timestamps

    end
  end

  def down
    drop_table :corpora_objects
  end
end

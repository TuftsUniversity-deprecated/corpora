class AddCorporaObjects < ActiveRecord::Migration
  def up
    create_table :corpora_objects do |t|
       t.belongs_to :pid
       t.string :title, :null => false
       t.string :video
       t.string :transcript
       t.date :temporal, :null => false
       t.string :creator, :null => false
       t.belongs_to :collection
       t.belongs_to :media_type
       t.boolean :published
       t.timestamps
    end
  end

  def down
    drop_table :corpora_objects
  end
end

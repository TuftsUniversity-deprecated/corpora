class CreatePids < ActiveRecord::Migration
  def up
    create_table :pids do |t|
      t.string :pid, :null => false, :unique => true
      t.integer :corpora_object_id
    end
  end

  def down
    drop_table :pids
  end
end

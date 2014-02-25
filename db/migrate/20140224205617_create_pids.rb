class CreatePids < ActiveRecord::Migration
  def up
    create_table :pids do |t|
      t.string :pid, :null => false, :unique => true
    end
  end

  def down
    drop_table :pids
  end
end

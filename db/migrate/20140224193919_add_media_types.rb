class AddMediaTypes < ActiveRecord::Migration
  def up
    create_table :media_types do |t|
      t.string :media_type, :null => false, :unique => true
    end
  end

  def down
    drop_table :media_types
  end
end

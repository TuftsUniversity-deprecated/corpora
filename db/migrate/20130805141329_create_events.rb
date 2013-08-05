class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :description
      t.string :link
      t.string :name

      t.timestamps
    end
  end
end

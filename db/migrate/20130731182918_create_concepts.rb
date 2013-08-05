class CreateConcepts < ActiveRecord::Migration
  def change
    create_table :concepts do |t|
      t.string :description
      t.string :link
      t.string :name

      t.timestamps
    end
  end
end

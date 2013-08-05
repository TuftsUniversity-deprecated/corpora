class CreateFeatures < ActiveRecord::Migration
  def change
    create_table :features do |t|
      t.string :type
      t.string :name
      t.string :description
      t.string :link

      t.timestamps
    end
  end
end

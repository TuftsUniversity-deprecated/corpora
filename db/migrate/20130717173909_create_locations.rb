class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :name
      t.string :description
      t.string :link
      t.string :modern_location
      t.string :historical_name
      t.string :admin01
      t.string :admin02
      t.string :town
      t.string :location_type
      t.string :variable_names
      t.float :latitutde
      t.float :longitude
      t.integer :external_feature_id

      t.timestamps
    end
  end
end

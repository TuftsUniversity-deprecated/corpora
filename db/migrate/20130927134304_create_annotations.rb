class CreateAnnotations < ActiveRecord::Migration
  def change
    create_table :annotations do |t|
      t.string :pid
      t.string :json
      t.string :text
      t.timestamps
    end
  end
end

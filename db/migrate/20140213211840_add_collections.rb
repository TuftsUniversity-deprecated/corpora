class AddCollections < ActiveRecord::Migration
    def up
      create_table :collections do |t|
         t.string :title, :null => false, :unique => true
      end
    end

    def down
      drop_table :collections
    end
end



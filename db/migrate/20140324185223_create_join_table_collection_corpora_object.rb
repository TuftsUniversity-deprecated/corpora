class CreateJoinTableCollectionCorporaObject < ActiveRecord::Migration
  def change
    create_join_table :collections, :corpora_objects do |t|
      # t.index [:collection_id, :corpora_object_id]
      # t.index [:corpora_object_id, :collection_id]
    end
  end
end

class SupportLongerFieldValues < ActiveRecord::Migration
  def up
      change_column :people, :description, :text
      change_column :concepts, :description, :text
  end

  def down
      change_column :people, :description, :string
      change_column :concepts, :description, :string
  end
end

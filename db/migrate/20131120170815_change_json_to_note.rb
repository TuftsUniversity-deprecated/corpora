class ChangeJsonToNote < ActiveRecord::Migration

  def up
    change_column :annotations, :json, :text
  end

  def down
  end
end

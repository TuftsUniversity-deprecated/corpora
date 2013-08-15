class AddAlternativeNameToConcepts < ActiveRecord::Migration
  def change
    add_column :concepts, :alternative_names, :string
  end
end

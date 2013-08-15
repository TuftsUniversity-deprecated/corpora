class AddAlternativeNameToPeople < ActiveRecord::Migration
  def change
    add_column :people, :alternative_names, :string
  end
end

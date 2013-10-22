class AddConceptToAnnotations < ActiveRecord::Migration
  def change
    add_column :annotations, :term, :string
    add_column :annotations, :term_type, :string
  end
end

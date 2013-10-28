class AddUtteranceToAnnotations < ActiveRecord::Migration
  def change
    add_column :annotations, :utterance, :string
  end
end

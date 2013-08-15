class AddImageLinkToConcepts < ActiveRecord::Migration
  def change
    add_column :concepts, :image_link, :string
  end
end

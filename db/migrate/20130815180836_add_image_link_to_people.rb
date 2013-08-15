class AddImageLinkToPeople < ActiveRecord::Migration
  def change
    add_column :people, :image_link, :string
  end
end

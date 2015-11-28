class AddProductIndex < ActiveRecord::Migration
  def change
    add_index :products, :name
    add_index :products, :url_name
  end
end

class CategoriesProducts < ActiveRecord::Migration
  def change
    create_join_table :products, :categories
  end
end

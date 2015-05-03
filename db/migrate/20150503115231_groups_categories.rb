class GroupsCategories < ActiveRecord::Migration
  def change
    create_join_table :categories, :groups
  end
end

class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :url
      t.string :name
      t.string :name_ru
      t.boolean :is_new
#      t.references :group, index: true, foreign_key: true

      #t.timestamps null: false
    end
  end
end

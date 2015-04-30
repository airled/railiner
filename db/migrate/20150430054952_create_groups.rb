class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name
      t.string :name_ru

      #t.timestamps null: false
    end
  end
end

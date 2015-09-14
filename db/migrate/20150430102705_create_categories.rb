class CreateCategories < ActiveRecord::Migration
  def change
    create_table(:categories, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8') do |t|
      t.string :url
      t.string :name
      t.string :name_ru
    end
  end
end

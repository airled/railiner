class CreateGroups < ActiveRecord::Migration
  def change
    create_table(:groups, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8') do |t|
      t.string :name
      t.string :name_ru
    end
  end
end

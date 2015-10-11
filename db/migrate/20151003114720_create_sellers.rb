class CreateSellers < ActiveRecord::Migration
  def change
    create_table(:sellers, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8') do |t|
      t.string :onliner_id
      t.string :name
    end
  end
end

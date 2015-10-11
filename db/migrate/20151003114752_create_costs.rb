class CreateCosts < ActiveRecord::Migration
  def change
    create_table(:costs, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8') do |t|
      t.integer :product_id
      t.integer :seller_id
      t.string :price
    end
  end
end

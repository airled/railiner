class CreateCosts < ActiveRecord::Migration
  def change
    create_table :costs do |t|
      t.integer :product_id
      t.integer :seller_id
      t.string :price
    end
  end
end

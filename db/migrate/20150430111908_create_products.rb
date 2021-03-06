class CreateProducts < ActiveRecord::Migration
  def change
    create_table(:products, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8') do |t|
      t.string :url
      t.string :name
      t.string :url_name
      t.string :small_image_url
      t.string :large_image_url
      t.integer :max_price, :limit => 8
      t.integer :min_price, :limit => 8
      t.text :description
      t.index :name
      t.index :url_name
      t.timestamps null: false
    end
  end
end

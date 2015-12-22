class CreateProducts < ActiveRecord::Migration
  def change
    create_table(:products, options: 'ENGINE=InnoDB DEFAULT CHARSET=utf8') do |t|
      t.string :url
      t.string :name
      t.string :url_name
      t.string :small_image_url
      t.string :large_image_url
      t.integer :max_price
      t.integer :min_price
      t.text :description
    end
  end
end

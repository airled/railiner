class ProductsController < ApplicationController

  def index
    @products = Product.all.page(params[:page])
  end

  def find
    request = params[:form][:product]
    if params[:form][:out] == '0'
      @products = Product.where("name like ?", "%#{request}%").where("min_price !=?", "N/A").page(params[:page])
    else
      @products = Product.where("name like ?", "%#{request}%").page(params[:page])
    end
  end

  # autocomplete :product, :name

  def autocomplete_product_name
    term = params[:term]
    products = Product.select(:name).distinct.where('name LIKE ?', "#{term}%").take(10)
    render :json => products.map { |product| {id: product.id, label: product.name, value: product.name} }
  end
  
end

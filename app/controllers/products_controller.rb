class ProductsController < ApplicationController

  def find
    request = params[:form][:product]
    if request.length < 2
      redirect_to :back
    else
      if params[:form][:out] == '0'
        @products = Product.where("name like ?", "#{request}%").where("min_price !=?", "N/A").group(:url_name).page(params[:page])
      else
        @products = Product.where("name like ?", "#{request}%").group(:url_name).page(params[:page])
      end
    end
  end

  def autocomplete_product_name
    term = params[:term]
    products = Product.select(:name).distinct.where('name LIKE ?', "#{term}%").take(10)
    render :json => products.map { |product| {id: product.id, label: product.name, value: product.name} }
  end

  def show
    @product = Product.find_by(url_name: params[:url_name])
  end
  
end

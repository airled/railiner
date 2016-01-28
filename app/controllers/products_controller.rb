class ProductsController < ApplicationController

  def find
    @request = params[:form][:product]
    if @request.length < 2
      redirect_to :back
    else
      if params[:form][:out] == '0'
        products = Product.where("name like ?", "#{@request}%").where.not(min_price: nil).group(:url_name)
      else
        products = Product.where("name like ?", "#{@request}%").group(:url_name)
      end
      @amount = products.count.count
      @products = products.page(params[:page])
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

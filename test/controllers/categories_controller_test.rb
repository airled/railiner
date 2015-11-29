require 'test_helper'

class CategoriesControllerTest < ActionController::TestCase

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:categories)
  end

  test 'index should render correct template' do
    get :index
    assert_template :index
  end
  
  test "should get show" do
  	category_name = Category.first.name
    get :show, category_name: category_name
    assert_response :success
    assert_not_nil assigns(:products)
  end

  test 'show should render correct template' do
    category_name = Category.first.name
    get :show, category_name: category_name
    assert_template :show
  end
  
end

require 'test_helper'

class CategoriesControllerTest < ActionController::TestCase

  test "should get index_all" do
    get :index_all
    assert_response :success
    assert_not_nil assigns(:categories)
  end

  test 'index_all should render correct template' do
    get :index_all
    assert_template :index_all
  end

  test "should get index" do
  	group_name = Group.first.name
    get :index, group_name: group_name
    assert_response :success
    assert_not_nil assigns(:categories)
  end

  test 'index should render correct template' do
    group_name = Group.first.name
    get :index, group_name: group_name
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

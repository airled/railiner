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
  	group_id = Group.first.id
    get :index, group_id: group_id
    assert_response :success
    assert_not_nil assigns(:categories)
  end

  test 'index should render correct template' do
    group_id = Group.first.id
    get :index, group_id: group_id
    assert_template :index
  end

  test "should get show" do
  	id = Category.first.id
    get :show, id: id
    assert_response :success
    assert_not_nil assigns(:products)
  end

  test 'show should render correct template' do
    id = Category.first.id
    get :show, id: id
    assert_template :show
  end
  
end

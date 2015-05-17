require 'test_helper'

class ProductsControllerTest < ActionController::TestCase

  test "should get index_all" do
    get :index_all
    assert_response :success
    assert_not_nil assigns(:products)
  end

  test 'index_all should render correct template' do
    get :index_all
    assert_template :index_all
  end

  # test "should get index" do
  # 	# group_id = Group.first.id
  # 	group = Group.first
  # 	group_id = group.id
  # 	category_id = group.categories.first.id

  #   get :index, group_id: group_id, catewgory_id: categories_id
  #   assert_response :success
  #   assert_not_nil assigns(:categories)
  # end

end

require 'test_helper'

class ProductsControllerTest < ActionController::TestCase

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:products)
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

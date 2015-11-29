require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:groups)
  end

  test 'index should render correct template' do
    get :index
    assert_template :index
  end

  test "should get show" do
    group_name = Group.first.name
    get :show, name: group_name
    assert_response :success
    assert_not_nil assigns(:categories)
  end

  test 'show should render correct template' do
    group_name = Group.first.name
    get :show, name: group_name
    assert_template :show
  end
  
end

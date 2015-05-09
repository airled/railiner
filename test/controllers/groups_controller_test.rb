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
  
end

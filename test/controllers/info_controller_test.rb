require 'test_helper'

class InfoControllerTest < ActionController::TestCase
  test "should get stats" do
    get :stats
    assert_response :success
  end

end

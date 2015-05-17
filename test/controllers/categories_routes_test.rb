class CategoriesRoutesTest < ActionController::TestCase
  test "should route to categories" do
    assert_routing '/groups', { controller: "groups", action: "index" }
  end
end
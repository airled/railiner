class CategoriesRoutesTest < ActionController::TestCase
  test "should route to categories" do
    assert_routing '/categories', { controller: "categories", action: "index_all" }
  end
end
class CategoriesRoutesTest < ActionController::TestCase

  test "should route to categories" do
    assert_routing '/categories', { controller: "categories", action: "index" }
  end

  test "should route to categories/show" do
    assert_routing '/categories/blabla', { controller: "categories", action: "show", category_name: "blabla" }
  end

end

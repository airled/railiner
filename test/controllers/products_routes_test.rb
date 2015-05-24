class ProductsRoutesTest < ActionController::TestCase
  test "should route to products" do
    assert_routing '/products', { controller: "products", action: "index" }
  end
end
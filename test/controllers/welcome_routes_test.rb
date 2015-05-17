class WelcomeRoutesTest < ActionController::TestCase
  test "should route to roots" do
    assert_routing '/', { controller: "welcome", action: "index" }
  end
end
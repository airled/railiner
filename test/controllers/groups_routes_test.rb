class GroupsRoutesTest < ActionController::TestCase
  test "should route to groups" do
    assert_routing '/groups', { controller: "groups", action: "index" }
  end
end

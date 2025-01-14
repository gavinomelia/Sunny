require "test_helper"

class LocationTest < ActiveSupport::TestCase
  test "valid location" do
    @user = users(:one)
    location = Location.new(name: "Park", latitude: 40.7128, longitude: -74.0060, user: @user)
      assert location.valid?, "Location should be valid, but errors were: #{location.errors.full_messages}"
  end

  test "invalid without name" do
    location = Location.new(latitude: 40.7128, longitude: -74.0060, user: @user)
    refute location.valid?
    assert_includes location.errors[:name], "can't be blank"
  end

  test "invalid without user" do
    location = Location.new(latitude: 40.7128, longitude: -74.0060)
    refute location.valid?
  end

  test "invalid latitude out of range" do
    location = Location.new(name: "Park", latitude: 100.0, longitude: -74.0060, user: @user)
    refute location.valid?
    assert_includes location.errors[:latitude], "must be less than or equal to 90"
  end

  test "invalid longitude out of range" do
    location = Location.new(name: "Park", latitude: 40.7128, longitude: 200.0, user: @user)
    refute location.valid?
    assert_includes location.errors[:longitude], "must be less than or equal to 180"
  end
end


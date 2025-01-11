require "test_helper"

class UserTest < ActiveSupport::TestCase

  test "valid user is saved" do
    user = User.new(email: "test@example.com", password: "password", password_confirmation: "password")
    assert user.save, "User should be saved"
  end

  test "invalid user without email" do
    user = User.new(password: "password", password_confirmation: "password")
    assert_not user.save, "User without email should not be saved"
  end

  test "password confirmation must match" do
    user = User.new(email: "test@example.com", password: "password", password_confirmation: "wrongpassword")
    assert_not user.save, "User with mismatched password confirmation should not be saved"
  end

  test "authenticate with valid credentials" do
    user = User.find_by(email: 'user1@example.com')
    assert Sorcery::CryptoProviders::BCrypt.matches?(user.crypted_password, "password123"), "Password should match"
  end

  test "fail authentication with invalid credentials" do
    user = User.find_by(email: 'user1@example.com')
    refute Sorcery::CryptoProviders::BCrypt.matches?(user.crypted_password, "wrongpassword"), "Password should not match"
  end

end

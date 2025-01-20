module SorceryHelpers
  def login_as(user)
    page.driver.post(login_path, params: { email: user.email, password: user.password })
  end
end


module SorceryHelpers
  def login_user(user)
    visit login_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: 'password123' 
    click_button 'Login'
  end
end


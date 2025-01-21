class SessionsController < ApplicationController
  def new
    if logged_in?
      redirect_to locations_path
    end
  end

  def create
    user = login(params[:email], params[:password])
    if user
      redirect_to root_path, notice: "Logged in successfully."
    else
      redirect_to login_path, notice: "Invalid email or password."
    end
  end

  def destroy
    logout
    redirect_to login_path, notice: "Logged out successfully."
  end
end

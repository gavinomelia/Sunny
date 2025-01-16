require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let(:user) { create(:user) }

  describe "GET #new" do
    it "renders the new session page" do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    context "with valid credentials" do
      it "logs the user in and redirects to the root path" do
        post :create, params: { email: user.email, password: 'password123' }
        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("Logged in successfully.")
        expect(session[:user_id].to_i).to eq(user.id)
      end
    end

    context "with invalid credentials" do
      it "redirects to the login page with an error message" do
        post :create, params: { email: user.email, password: 'wrongpassword' }
        expect(response).to redirect_to(login_path)
        expect(flash[:notice]).to eq("Invalid email or password.")
        expect(session[:user_id]).to be_nil
      end
    end
  end

  describe "DELETE #destroy" do
    context "when logged in" do
      before do
        login_user(user)
      end

      it "logs the user out and redirects to the login page" do
        delete :destroy
        expect(response).to redirect_to(login_path)
        expect(flash[:notice]).to eq("Logged out successfully.")
        expect(session[:user_id]).to be_nil
      end
    end

    context "when not logged in" do
      it "redirects to the login page" do
        delete :destroy
        expect(response).to redirect_to(login_path)
      end
    end
  end

  def login_user(user)
    session[:user_id] = user.id
  end
end


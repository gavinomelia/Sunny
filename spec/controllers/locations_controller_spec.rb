require 'rails_helper'

RSpec.describe LocationsController, type: :controller do
  let(:user) { create(:user) }
  let(:location) { create(:location, user: user) }
  let(:forecast_data) do
    {
      'current' => { 'temperature_2m' => 70, 'precipitation' => 30 },
      'daily' => {
        'time' => ['2025-01-16', '2025-01-17', '2025-01-18', '2025-01-19', '2025-01-20', '2025-01-21', '2025-01-22'],
        'temperature_2m_max' => [75, 76, 78, 79, 80, 81, 82],
        'temperature_2m_min' => [50, 51, 52, 53, 54, 55, 56],
        'precipitation_probability_max' => [10, 20, 30, 40, 50, 60, 70]
      }
    }
  end

  before { session[:user_id] = user.id }

  describe "GET #index" do
    it "returns a successful response with assigned locations" do
      get :index
      expect(response).to be_successful
      expect(assigns(:locations)).to eq([location])
    end

    it "redirects to login if user is not logged in" do
      session[:user_id] = nil
      get :index
      expect(response).to redirect_to(login_path)
    end
  end

  describe "GET #forecast" do
    before { allow(ForecastService).to receive(:fetch_forecast).and_return(forecast_data) }

    it "fetches and assigns forecast data" do
      get :forecast, params: { id: location.id }
      expect(response).to render_template(:show)
      
      expect(assigns(:current_conditions)['temperature_2m']).to eq(70)
      expect(assigns(:forecast)['daily']['temperature_2m_max']).to eq([75, 76, 78, 79, 80, 81, 82])
      expect(assigns(:chart_url)).to be_present
    end
  end

  describe "POST #create" do
    it "creates a location and redirects to locations path" do
      post :create, params: { location: { name: 'New Location', latitude: 35.6895, longitude: 139.6917 } }
      expect(response).to redirect_to(locations_path)
      expect(flash[:notice]).to eq("Location saved successfully.")
    end
  end

  describe "DELETE #destroy" do
    it "deletes a location and redirects to locations path" do
      delete :destroy, params: { id: location.id }
      expect(response).to redirect_to(locations_path)
      expect(flash[:notice]).to eq("Location deleted successfully.")
    end
  end
 end


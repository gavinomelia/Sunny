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

  describe "POST #current_location_forecast" do
    before { allow(Net::HTTP).to receive(:get).and_return('{"latitude": 35.6895, "longitude": 139.6917, "city": "Tokyo", "region": "Tokyo"}') }

    it "saves the current location and redirects" do
      post :current_location_forecast
      expect(response).to redirect_to(locations_path)
      expect(flash[:notice]).to eq("Location successfully saved!")
    end

    it "handles error when location cannot be determined" do
      allow(Net::HTTP).to receive(:get).and_return('{}')
      post :current_location_forecast
      expect(response).to redirect_to(locations_path)
      expect(flash[:alert]).to eq("Unable to determine your location. Please try again.")
    end
  end

  describe "POST #geocode_address" do
    let(:valid_address) { 'Tokyo' }
    let(:invalid_address) { 'Invalid Address' }

    before { allow_any_instance_of(LocationsController).to receive(:fetch_location_data) }

    it "geocodes a valid address and redirects to locations path" do
      allow_any_instance_of(LocationsController).to receive(:fetch_location_data).and_return({ 'latt' => 35.6895, 'longt' => 139.6917, 'standard' => { 'addresst' => valid_address } })
      post :geocode_address, params: { address: valid_address }
      expect(response).to redirect_to(locations_path)
      expect(flash[:notice]).to eq("Location successfully saved!")
    end

    it "shows an error when geocoding fails" do
      allow_any_instance_of(LocationsController).to receive(:fetch_location_data).and_return(nil)
      post :geocode_address, params: { address: invalid_address }
      expect(response).to redirect_to(locations_path)
      expect(flash[:alert]).to eq("Unable to find that address. Please try again.")
    end
  end
end


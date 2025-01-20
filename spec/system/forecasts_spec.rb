require 'rails_helper'

RSpec.describe 'Locations Index Page', type: :system do
  let(:user) { create(:user) }  # Assuming you have a factory for the User model
  let!(:location) { create(:location, name: 'New York', latitude: 40.7128, longitude: -74.0060) }

  before do
    login_as(user)  # Log in the user before visiting the page
    driven_by(:rack_test)  # Use rack_test for system tests, or :selenium for browser-based tests
  end

  it 'displays a list of locations with their details and links' do
    visit locations_path

    expect(page).to have_content('Your Locations')
    expect(page).to have_content('New York')
    expect(page).to have_content('(40.7128, -74.0060)')
    expect(page).to have_link('Get Forecast', href: forecast_location_path(location))
    expect(page).to have_link('Delete', href: location_path(location))
  end
end


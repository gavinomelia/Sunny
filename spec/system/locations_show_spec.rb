require 'rails_helper'

RSpec.describe 'Location Show Forecast Page', type: :system do
  let(:user) { create(:user) }
  let!(:location) { create(:location, user: user) }

  before do
    driven_by(:rack_test)
    login_user(user)

    VCR.use_cassette('forecast') do
      visit forecast_location_path(location)
    end
  end

  it 'displays the forecast for a location' do
    # Ensure correct location content
    expect(page).to have_content('Forecast for Sample Location')
    
    # Verify current weather details
    expect(page).to have_content('Temperature: 42.3°F')
    expect(page).to have_content('Current Chance of Precipitation: 0.0%')

    # Verify forecast table headers
    expect(page).to have_content('Date')
    expect(page).to have_content('Max Temp (°F)')
    expect(page).to have_content('Min Temp (°F)')
    expect(page).to have_content('Precipitation Probability (%)')

    # Verify forecast data
    expect(page).to have_content('Jan 21, 2025')
    expect(page).to have_content('52.1')
    expect(page).to have_content('51.8')
    expect(page).to have_content('7%')
  end
end

require 'rails_helper'

RSpec.describe 'Locations Index Page', type: :system do
  let(:user) { create(:user) }
  let!(:location) { create(:location, user: user) }

  before do
    driven_by(:rack_test)
    login_user(user)
  end

  it 'displays a list of locations with their details and links' do
    visit locations_path

    expect(page).to have_content('Your Locations')
    expect(page).to have_content('Sample Location')
    expect(page).to have_content('(35.6895, 139.6917)')
    expect(page).to have_link('Get Forecast', href: forecast_location_path(location))
    expect(page).to have_link('Delete', href: location_path(location))
  end
end

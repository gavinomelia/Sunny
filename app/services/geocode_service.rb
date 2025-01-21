class GeocodeService
  require 'net/http'
  require 'json'

  def initialize(address)
    @address = address
    @api_key = Rails.application.credentials.geocode_api_key
  end

  def fetch_location_data
    return { success: false, error: "Address cannot be blank." } if @address.blank?

    api_url = URI("https://geocode.xyz/#{URI.encode_www_form_component(@address)}?json=1&auth=#{@api_key}")
    response = Net::HTTP.get(api_url)
    location_data = JSON.parse(response)

    if location_data.nil? || location_data['error']
      { success: false, error: "Unable to find that address. Please try again." }
    else
      {
        success: true,
        latitude: location_data['latt'],
        longitude: location_data['longt'],
        name: location_data.dig("standard", "addresst").titleize || location_data.dig("standard", "city").titleize || "Unknown Address"
      }
    end
  rescue JSON::ParserError, StandardError => e
    Rails.logger.error "Failed to fetch or parse location data: #{e.message}"
    { success: false, error: "An error occurred while processing the address. Please try again." }
  end
end 

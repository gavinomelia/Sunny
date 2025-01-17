require 'net/http'
require 'json'

class CurrentLocationService
  BASE_URL = 'https://ipapi.co/json'.freeze

  def fetch
    location_data = fetch_location_from_api 

    if valid_location_data?(location_data)
      success_response(location_data)
    else
      error_response("Unable to determine your location.")
    end
  rescue StandardError => e
    error_response(e.message)
  end

  def save(user, location_data)
    location = build_location(user, location_data)

    if location.save
      success_response(message: "Location successfully saved!")
    else
      error_response("Unable to save the location. #{location.errors.full_messages.to_sentence}")
    end
  end

  private

  def fetch_location_from_api
    response = Net::HTTP.get(URI.parse(BASE_URL))
    JSON.parse(response, symbolize_names: true)
  end

  def valid_location_data?(data)
    data.present? && data[:latitude] && data[:longitude]
  end

  def success_response(data = {})
    { success: true }.merge(data)
  end

  def error_response(message)
    { success: false, error: message }
  end

  def build_location(user, data)
    city = data[:city] || "Unknown City"
    state = data[:region] || "Unknown State"
    user.locations.build(
      name: "#{city}, #{state}",
      latitude: data[:latitude],
      longitude: data[:longitude]
    )
  end
end


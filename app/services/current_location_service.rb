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

  private

  def fetch_location_from_api
    response = Net::HTTP.get(URI.parse(BASE_URL))
    data = JSON.parse(response, symbolize_names: true)

    {
      latitude: data[:latitude],
      longitude: data[:longitude],
      name: "#{data[:city] || 'Unknown City'}, #{data[:region] || 'Unknown State'}" }
  end

  def valid_location_data?(data)
    data[:latitude].present? && data[:longitude].present?
  end

  def success_response(data = {})
    { success: true }.merge(data)
  end

  def error_response(message)
    { success: false, error: message }
  end
end


require 'net/http'
require 'json'

class CurrentLocationService
  def fetch
    url = URI.parse('https://ipapi.co/json')
    response = Net::HTTP.get(url)
    location_data = JSON.parse(response)

    if location_data.present? && location_data["latitude"] && location_data["longitude"]
      {
        success: true,
        latitude: location_data["latitude"],
        longitude: location_data["longitude"],
        city: location_data["city"],
        state: location_data["region"]
      }
    else
      { success: false, error: "Unable to determine your location." }
    end
  rescue StandardError => e
    { success: false, error: e.message }
  end

  def save(user, location_data)
    location = user.locations.build(
      name: "#{location_data[:city]}, #{location_data[:state]}",
      latitude: location_data[:latitude],
      longitude: location_data[:longitude]
    )

    if location.save
      { success: true, message: "Location successfully saved!" }
    else
      { success: false, message: "Unable to save the location. #{location.errors.full_messages.to_sentence}" }
    end
  end
end


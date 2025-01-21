require 'net/http'
require 'json'

class ForecastService
  def self.fetch_forecast(latitude, longitude)
    url = URI("https://api.open-meteo.com/v1/forecast?latitude=#{latitude}&longitude=#{longitude}&current=temperature_2m,precipitation&daily=temperature_2m_max,temperature_2m_min,precipitation_probability_max&temperature_unit=fahrenheit&timezone=America/New_York")
    response = Net::HTTP.get(url)
    JSON.parse(response)
  rescue StandardError => e
    Rails.logger.error("ForecastService Error: #{e.message}")
    nil
  end
end


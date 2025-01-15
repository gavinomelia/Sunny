require 'test_helper'
require 'minitest/mock'

class OpenMeteoServiceTest < ActiveSupport::TestCase
  def setup
    @latitude = 52.52
    @longitude = 13.419998

    @mock_response = {
      "latitude" => @latitude,
      "longitude" => @longitude,
      "generationtime_ms" => 0.06377696990966797,
      "utc_offset_seconds" => -18000,
      "timezone" => "America/New_York",
      "timezone_abbreviation" => "GMT-5",
      "elevation" => 38.0,
      "current_units" => {
        "time" => "iso8601",
        "interval" => "seconds",
        "temperature_2m" => "°F",
        "precipitation" => "inch"
      },
      "current" => {
        "time" => "2025-01-11T12:00",
        "interval" => 900,
        "temperature_2m" => 32.5,
        "precipitation" => 0.008
      },
      "daily_units" => {
        "time" => "iso8601",
        "temperature_2m_max" => "°F",
        "temperature_2m_min" => "°F",
        "precipitation_probability_max" => "%"
      },
      "daily" => {
        "time" => ["2025-01-11", "2025-01-12", "2025-01-13", "2025-01-14", "2025-01-15", "2025-01-16", "2025-01-17"],
        "temperature_2m_max" => [34.6, 34.3, 30.3, 35.4, 40.4, 42.1, 44.4],
        "temperature_2m_min" => [31.5, 27.6, 26.2, 27.5, 35.9, 37.3, 37.1],
        "precipitation_probability_max" => [78, 30, 1, 25, 23, 11, 8]
      }
    }.to_json
  end

  test 'fetches weather data successfully' do
    # Mocking Net::HTTP.get
    Net::HTTP.stub :get, @mock_response do
      response = ForecastService.fetch_forecast(@latitude, @longitude)

      assert response.is_a?(Hash), 'Response should be a hash'
      assert_equal 34.6, response.dig('daily', 'temperature_2m_max').first
      assert_equal 32.5, response.dig('current', 'temperature_2m')
      assert_equal 31.5, response.dig('daily', 'temperature_2m_min').first
      assert_equal 78, response.dig('daily', 'precipitation_probability_max').first
    end
  end

  test 'returns nil on invalid response' do
    # Mocking Net::HTTP.get to return nil
    Net::HTTP.stub :get, nil do
      response = ForecastService.fetch_forecast(@latitude, @longitude)

      assert_nil response, 'Response should be nil for invalid requests'
    end
  end
end


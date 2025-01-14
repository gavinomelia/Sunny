class LocationsController < ApplicationController
  require 'net/http'
  require 'json'
  before_action :set_location, only: [ :show, :edit, :update, :destroy, :forecast ]

  def index
    @locations = current_user.locations
  end

  def forecast
    @forecast = ForecastService.fetch_forecast(@location.latitude, @location.longitude)

    if @forecast
      render :show
    else
      redirect_to locations_path, alert: "Unable to fetch forecast. Try again later."
    end
  end

  def new
    @location = Location.new
  end

  def create
    @location = current_user.locations.build(location_params)
    if @location.save
      redirect_to locations_path, notice: "Location saved successfully."
    else
      render :index, alert: "Failed to add location."
    end
  end

  def edit
  end

  def update
    if @location.update(location_params)
      redirect_to locations_path, notice: "Location updated successfully."
    else
      render :edit, alert: "Unable to update location."
    end
  end

  def destroy
    @location = current_user.locations.find(params[:id])
    @location.destroy
    redirect_to locations_path, notice: "Location deleted successfully."
  end

  def current_location_forecast
    url = URI.parse('https://ipapi.co/json')
    response = Net::HTTP.get(url)
    location_data = JSON.parse(response)

    if location_data.present? && location_data["latitude"] && location_data["longitude"]
      @latitude = location_data["latitude"]
      @longitude = location_data["longitude"]
      @city = location_data["city"]
      @state = location_data["region"]

      # Save the location for the current user
      location = current_user.locations.build(
        name: "#{@city}, #{@state}",
        latitude: @latitude,
        longitude: @longitude
      )

      if location.save
        flash[:notice] = "Location successfully saved!"
        redirect_to locations_path
      else
        flash[:alert] = "Unable to save the location. #{location.errors.full_messages.to_sentence}"
        redirect_to locations_path
      end
    else
      flash[:alert] = "Unable to determine your location. Please try again."
      redirect_to locations_path
    end
  end

  def geocode_address
    address = params[:address]
    if address.blank?
      flash[:alert] = "Please provide a valid address."
      return redirect_to locations_path
    end

    location_data = fetch_location_data(address)

    if location_data.nil? || location_data['error']
      handle_geocode_error(location_data)
      return redirect_to locations_path
    end

    latitude = location_data['latt']
    longitude = location_data['longt']
    location_name = location_data.dig("standard", "addresst") || location_data.dig("standard", "city") || "Unknown Address"

    save_location(latitude, longitude, location_name.capitalize)
    redirect_to locations_path
  end

  private

  def fetch_location_data(address)
    api_url = URI("https://geocode.xyz/#{URI.encode_www_form_component(address)}?json=1&auth=#{Rails.application.credentials.geocode_api_key}")
    response = Net::HTTP.get(api_url)
    JSON.parse(response)
  rescue JSON::ParserError, StandardError => e
    Rails.logger.error "Failed to fetch or parse location data: #{e.message}"
    nil
  end

  def handle_geocode_error(location_data)
    error_message = location_data&.dig('error', 'description') || "Unable to geocode the address. Please try again."
    flash[:alert] = "Error: #{error_message}"
  end

  def save_location(latitude, longitude, location_name)
    location = current_user.locations.build(name: location_name, latitude: latitude, longitude: longitude)

    if location.save
      flash[:notice] = "Location successfully saved!"
    else
      flash[:alert] = "Unable to save location. #{location.errors.full_messages.to_sentence}"
    end
  end

  def set_location
    @location = current_user.locations.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:name, :latitude, :longitude)
  end
end

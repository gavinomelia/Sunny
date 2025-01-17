class LocationsController < ApplicationController
  require 'net/http'
  require 'json'
  before_action :require_login
  before_action :set_location, only: [ :show, :edit, :update, :destroy, :forecast ]

  def index
    return redirect_to :login unless logged_in?
    @locations = current_user.locations
  end

  def forecast
    @forecast = ForecastService.fetch_forecast(@location.latitude, @location.longitude)

    if @forecast
      @current_conditions = @forecast['current']
      @chart_url = generate_chart_url(@forecast)
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

  def get_current_location
    service = CurrentLocationService.new
    current_location = service.fetch

    if current_location[:success]
      save_result = service.save(current_user, current_location)
      flash[save_result[:success] ? :notice : :alert] = save_result[:message]
    else
      flash[:alert] = current_location[:error]
    end

    redirect_to locations_path
  end

  def geocode_address
    address = params[:address]
    if address.blank?
      flash[:alert] = "Please provide a valid address."
      return redirect_to locations_path
    end

    location_data = fetch_location_data(address)

    if location_data.nil? || location_data['error']
      flash[:alert] = "Unable to find that address. Please try again."
      return redirect_to locations_path
    end

    latitude = location_data['latt']
    longitude = location_data['longt']
    location_name = location_data.dig("standard", "addresst") || location_data.dig("standard", "city") || "Unknown Address"

    save_location(latitude, longitude, location_name)
    redirect_to locations_path
  end

  private

  def generate_chart_url(forecast)
    max_temps = forecast['daily']['temperature_2m_max'].join(',')
    min_temps = forecast['daily']['temperature_2m_min'].join(',')
    dates = forecast['daily']['time'].map { |date| Date.parse(date).strftime('%b %d') }

    base_url = "https://image-charts.com/chart"
    query_params = {
      chbh: 'a',
      chbr: '10',
      chco: 'fdb45c,1869b7',
      chd: "t:#{max_temps}|#{min_temps}",
      chds: '-20,120', 
      chm: 'N,000000,0,,10|N,000000,1,,10', 
      chma: '0,0,10,10',
      chs: '900x350',
      cht: 'bvg',
      chxs: '0,000000,12,0,_,000000|1,000000,12,0,_',
      chxt: 'x',
      chxl: "0:|#{dates.join('|')}|1"
    }

    "#{base_url}?#{query_params.to_query}"
  end

  def fetch_location_data(address)
    api_url = URI("https://geocode.xyz/#{URI.encode_www_form_component(address)}?json=1&auth=#{Rails.application.credentials.geocode_api_key}")
    response = Net::HTTP.get(api_url)
    JSON.parse(response)
  rescue JSON::ParserError, StandardError => e
    Rails.logger.error "Failed to fetch or parse location data: #{e.message}"
    nil
  end

  def save_location(latitude, longitude, location_name)
    location = current_user.locations.build(name: location_name, latitude: latitude, longitude: longitude)

    if location.save
      flash[:notice] = "Location successfully saved!"
    else
      flash[:alert] = "Unable to save location. #{location.errors.full_messages.to_sentence}"
    end
  end

  def require_login
    unless logged_in?
      redirect_to login_path, alert: "You must be logged in to access this page."
    end
  end

  def set_location
    @location = current_user.locations.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:name, :latitude, :longitude)
  end
end

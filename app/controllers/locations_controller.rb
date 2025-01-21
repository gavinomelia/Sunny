class LocationsController < ApplicationController
  require 'net/http'
  require 'json'
  before_action :require_login
  before_action :set_location, only: [ :show, :edit, :update, :destroy, :forecast ]

  def index
    @locations = current_user.locations
  end

  def forecast
    @forecast = ForecastService.fetch_forecast(@location.latitude, @location.longitude)

    if @forecast
      @current_conditions = @forecast['current']
      @chart_url = ChartGenerator.new(@forecast).generate
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
      save_result = Location.create_from_data(current_user, current_location)

      flash[save_result[:success] ? :notice : :alert] = save_result[:message]
    else
      flash[:alert] = current_location[:error]
    end

    redirect_to locations_path
  end

  def geocode_address
    address = params[:address]

    geocode_service = GeocodeService.new(address)
    location_result = geocode_service.fetch_location_data

    unless location_result[:success]
      flash[:alert] = location_result[:error]
      return redirect_to new_location_path
    end

    result = Location.create_from_data(current_user, {
      latitude: location_result[:latitude],
      longitude: location_result[:longitude],
      name: location_result[:name]
    })

    flash[result[:success] ? :notice : :alert] = result[:message]
    redirect_to locations_path
  end

  private

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

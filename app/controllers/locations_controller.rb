class LocationsController < ApplicationController
  before_action :set_location, only: [:show, :edit, :update, :destroy, :forecast]

  def index
    @locations = current_user.locations
  end

  def forecast
    @forecast = ForecastService.fetch_forecast(@location.latitude, @location.longitude)

    if @forecast
      render :show
    else
      redirect_to locations_path, alert: 'Unable to fetch forecast. Try again later.'
    end
  end

  def new
    @location = Location.new
  end

  def create
    @location = current_user.locations.build(location_params)
    if @location.save
      redirect_to locations_path, notice: 'Location saved successfully.'
    else
      render :index, alert: "Failed to add location."
    end
  end

  def edit
  end

  def update
    if @location.update(location_params)
      redirect_to locations_path, notice: 'Location updated successfully.'
    else
      render :edit, alert: "Unable to update location."
    end
  end

  def destroy
    @location = current_user.locations.find(params[:id])
    @location.destroy
    redirect_to locations_path, notice: 'Location deleted successfully.'
  end

  private

  def set_location
    @location = current_user.locations.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:name, :latitude, :longitude)
  end
end


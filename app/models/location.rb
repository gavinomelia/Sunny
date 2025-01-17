class Location < ApplicationRecord
  belongs_to :user
  validates :name, presence: true
  validates :latitude, presence: true, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, presence: true, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }

  def self.create_from_data(user, location_data)
    location = user.locations.build(
      name: location_data[:name],
      latitude: location_data[:latitude],
      longitude: location_data[:longitude]
    )

    if location.save
      { success: true, message: "Location successfully saved!" }
    else
      { success: false, error: "Unable to save the location." }
    end
  end
end


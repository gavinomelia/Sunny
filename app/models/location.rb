class Location < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :user, optional: true

  validates :name, presence: true
  validates :latitude, :longitude, presence: true
end

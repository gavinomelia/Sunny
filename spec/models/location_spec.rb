require 'rails_helper'

RSpec.describe Location, type: :model do
  let(:user) { create(:user) }

  describe "validations" do
    it "is valid with valid attributes" do
      location = Location.new(name: "Park", latitude: 40.7128, longitude: -74.0060, user: user)
      expect(location).to be_valid
    end

    it "is invalid without a name" do
      location = Location.new(latitude: 40.7128, longitude: -74.0060, user: user)
      expect(location).to be_invalid
      expect(location.errors[:name]).to include("can't be blank")
    end

    it "is invalid without a user" do
      location = Location.new(name: "Park", latitude: 40.7128, longitude: -74.0060)
      expect(location).to be_invalid
    end

      it 'is invalid without a latitude' do
      location = build(:location, user: user, latitude: nil)
      expect(location).not_to be_valid
    end

    it 'is invalid without a longitude' do
      location = build(:location, user: user, longitude: nil)
      expect(location).not_to be_valid
    end

    it "is invalid with a latitude out of range" do
      location = Location.new(name: "Park", latitude: 100.0, longitude: -74.0060, user: user)
      expect(location).to be_invalid
      expect(location.errors[:latitude]).to include("must be less than or equal to 90")
    end

    it "is invalid with a longitude out of range" do
      location = Location.new(name: "Park", latitude: 40.7128, longitude: 200.0, user: user)
      expect(location).to be_invalid
      expect(location.errors[:longitude]).to include("must be less than or equal to 180")
    end
  end

  describe ".create_from_data" do
    let(:location_data) do
      {
        latitude: 35.6895,
        longitude: 139.6917,
        name: "Tokyo, Tokyo",
      }
    end

    context "when the location is successfully created and saved" do
      it "returns a success response with a message" do
        result = Location.create_from_data(user, location_data)

        expect(result[:success]).to be(true)
        expect(result[:message]).to eq("Location successfully saved!")

        location = user.locations.last
        expect(location).to have_attributes(
          name: "Tokyo, Tokyo",
          latitude: 35.6895,
          longitude: 139.6917
        )
      end
    end

    context "when the location cannot be saved due to validation errors" do
      before do
        allow_any_instance_of(Location).to receive(:save).and_return(false)
        allow_any_instance_of(Location).to receive_message_chain(:errors, :full_messages).and_return(["Name can't be blank"])
      end

      it "returns a failure response with error messages" do
        result = Location.create_from_data(user, location_data)

        expect(result[:success]).to be(false)
        expect(result[:error]).to eq("Unable to save the location.")
      end
    end
  end
end


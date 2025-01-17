require 'rails_helper'

RSpec.describe CurrentLocationService, type: :service do
  let(:user) { create(:user) }
  let(:service) { described_class.new }

  describe "#fetch" do
    subject(:fetch_result) { service.fetch }

    context "when the API returns valid location data" do
      let(:valid_response) do
        {
          "latitude" => 35.6895,
          "longitude" => 139.6917,
          "city" => "Tokyo",
          "region" => "Tokyo"
        }.to_json
      end

      before { allow(Net::HTTP).to receive(:get).and_return(valid_response) }

      it "returns a success response with location data" do
        expect(fetch_result).to include(
          success: true,
          latitude: 35.6895,
          longitude: 139.6917,
          city: "Tokyo",
          state: "Tokyo"
        )
      end
    end

    context "when the API returns incomplete location data" do
      let(:incomplete_response) { { "city" => "Tokyo" }.to_json }

      before { allow(Net::HTTP).to receive(:get).and_return(incomplete_response) }

      it "returns an error response" do
        expect(fetch_result).to eq(success: false, error: "Unable to determine your location.")
      end
    end

    context "when an exception occurs" do
      before { allow(Net::HTTP).to receive(:get).and_raise(StandardError, "Connection error") }

      it "returns an error response with the exception message" do
        expect(fetch_result).to eq(success: false, error: "Connection error")
      end
    end
  end

  describe "#save" do
    let(:location_data) do
      {
        latitude: 35.6895,
        longitude: 139.6917,
        city: "Tokyo",
        state: "Tokyo"
      }
    end

    subject(:save_result) { service.save(user, location_data) }

    context "when the location is successfully saved" do
      it "returns a success response with a message" do
        expect(save_result).to eq(success: true, message: "Location successfully saved!")

        location = user.locations.last
        expect(location).to have_attributes(
          name: "Tokyo, Tokyo",
          latitude: 35.6895,
          longitude: 139.6917
        )
      end
    end

    context "when the location cannot be saved" do
      before do
        allow_any_instance_of(Location).to receive(:save).and_return(false)
        allow_any_instance_of(Location).to receive_message_chain(:errors, :full_messages).and_return(["Name can't be blank"])
      end

      it "returns a failure response with error messages" do
        expect(save_result).to eq(success: false, message: "Unable to save the location. Name can't be blank")
      end
    end
  end
end


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

      it "returns a success response with location data, including name" do
        expect(fetch_result).to include(
          success: true,
          latitude: 35.6895,
          longitude: 139.6917,
          name: "Tokyo, Tokyo"
        )
      end
    end

    context "when the API returns incomplete location data" do
      let(:incomplete_response) { { "latitude" => 35.6895 }.to_json }

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
end


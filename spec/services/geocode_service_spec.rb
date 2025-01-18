require 'rails_helper'

RSpec.describe GeocodeService, vcr: true do
  describe "#fetch_location_data" do
    let(:address) { "117 William St
Effingham, Kansas, 66023" }
    let(:service) { described_class.new(address) }

    context "when the address is valid" do
      it "returns the latitude, longitude, and address name" do
        VCR.use_cassette('geocode_service_valid_address') do
          result = service.fetch_location_data
          expect(result[:success]).to eq(true)
          expect(result[:latitude]).to eq("39.51776")
          expect(result[:longitude]).to eq("-95.40083")
          expect(result[:name]).to eq("WILLIAM ST")
        end
      end
    end

    context "when the address is invalid" do
      let(:address) { "" }

      it "returns an error when the address is blank" do
        VCR.use_cassette('geocode_service_invalid_address') do
          result = service.fetch_location_data
          expect(result[:success]).to eq(false)
          expect(result[:error]).to eq("Address cannot be blank.")
        end
      end
    end

    context "when the API responds with an error" do
      let(:address) { "Invalid Address" }

      it "returns an error when the API response is invalid" do
        VCR.use_cassette('geocode_service_invalid_address_response') do
          result = service.fetch_location_data
          expect(result[:success]).to eq(false)
          expect(result[:error]).to eq("Unable to find that address. Please try again.")
        end
      end
    end

    context "when the API request fails" do
      before do
        allow(Net::HTTP).to receive(:get).and_raise(StandardError.new("Connection error"))
      end

      it "returns an error when the request fails" do
        result = service.fetch_location_data
        expect(result[:success]).to eq(false)
        expect(result[:error]).to eq("An error occurred while processing the address. Please try again.")
      end
    end
  end
end

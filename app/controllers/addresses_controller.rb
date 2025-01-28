class AddressesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:lookup]

  def lookup
    postcode = params[:postcode]&.strip

    addresses = if postcode.present?
                  GoogleMapsService.lookup_addresses(postcode)
                else
                  []
                end

    render json: addresses
  end
end

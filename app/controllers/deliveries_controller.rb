class DeliveriesController < ApplicationController
  def available_dates
    postcode = params[:postcode]

    available_dates = DeliveryService.new(postcode).available_dates

    render json: { dates: available_dates }
  end
end

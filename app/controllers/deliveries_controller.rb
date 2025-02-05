class DeliveriesController < ApplicationController
  def available_dates
    order = Order.find(params[:order_id])

    unless order.address_complete?
      render json: { error: "Complete address required" }, status: :unprocessable_entity
      return
    end

    service = DeliveryService.new(order.display_postcode)
    available_dates = service.available_dates

    render json: {
      dates: available_dates.map { |date| date.strftime('%Y-%m-%d') }
    }
  rescue StandardError => e
    render json: {
      error: "Could not fetch available dates",
      details: e.message
    }, status: :unprocessable_entity
  end
end

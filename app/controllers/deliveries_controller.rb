class DeliveriesController < ApplicationController
  def available_dates
    order = Order.find(params[:order_id])

    unless order.address_complete?
      render json: { error: "Complete address required" }, status: :unprocessable_entity
      return
    end

    begin
      service = DeliveryService.new(order.display_postcode)
      available_dates = service.available_dates

      render json: {
        dates: available_dates.map { |date| date.strftime('%Y-%m-%d') }
      }
    rescue ArgumentError => e
      render json: {
        error: "Invalid postcode",
        details: e.message
      }, status: :unprocessable_entity
    rescue StandardError => e
      render json: {
        error: "Could not fetch available dates",
        details: e.message
      }, status: :unprocessable_entity
    end
  end
end

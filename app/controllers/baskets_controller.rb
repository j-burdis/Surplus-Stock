class BasketsController < ApplicationController
  include OrderCalculations
  def show
    @basket = current_user.basket
    @basket.clean_up_expired_items
    @basket_items = @basket.basket_items.includes(:item).order(:created_at)

    # Remove expired items and calculate remaining time
    @basket_items.each do |basket_item|
      next unless basket_item.expired?

      ActiveRecord::Base.transaction do
        basket_item.item.increment!(:stock, basket_item.quantity)
        basket_item.destroy
      end
    end

    # Remove expired orders if any
    current_user.orders.each do |order|
      order.destroy if order.expired?
    end

    # Reload basket items after cleanup
    @basket_items = @basket.basket_items.includes(:item).order(:created_at)
    @pending_order = current_user.orders.pending.first
    calculate_totals

    respond_to do |format|
      format.html
      format.json do
        html = render_to_string(
          partial: 'basket_summary',
          formats: [:html],
          layout: false
        )
        render json: {
          success: true,
          html: html
        }
      rescue StandardError => e
        render json: {
          success: false,
          error: e.message
        }, status: :internal_server_error
      end
    end
  end
end

class BasketsController < ApplicationController
  include OrderCalculations
  def show
    @basket = current_user.basket
    @basket_items = @basket.basket_items.includes(:item).order(:created_at)

    # Remove expired items and calculate remaining time
    @basket_items.each do |basket_item|
      next unless basket_item.expired?

      ActiveRecord::Base.transaction do
        basket_item.item.increment!(:stock, basket_item.quantity)
        basket_item.destroy
      end
    end

    # Reload basket items after cleanup
    @basket_items = @basket.basket_items.includes(:item).order(:created_at)
    @pending_order = current_user.orders.pending.first
    calculate_totals
  end
end

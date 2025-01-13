class BasketsController < ApplicationController
  include OrderCalculations
  def show
    @basket = current_user.basket
    @basket_items = @basket.basket_items.includes(:item)
    calculate_totals
  end
end

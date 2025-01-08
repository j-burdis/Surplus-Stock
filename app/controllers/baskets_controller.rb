class BasketsController < ApplicationController
  def show
    @basket = current_user.basket
    @basket_items = @basket.basket_items.includes(:item)
  end
end

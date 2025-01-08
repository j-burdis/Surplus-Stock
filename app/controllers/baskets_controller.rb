class BasketsController < ApplicationController
  def show
    @basket_items = current_user.basket_items
  end
end

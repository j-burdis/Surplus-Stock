class BasketItemsController < ApplicationController
  before_action :set_basket_item, only: %i[update destroy]
  def create
    item = Item.find(params[:item_id])
    quantity = params[:quantity].to_i
    basket = current_user.basket || Basket.create(user: current_user)
    basket_item = basket.basket_items.find_by(item: item)

    if basket_item
      # Increment the quantity by the value passed from the form
      basket_item.update(quantity: basket_item.quantity + quantity)
    else
      basket.basket_items.create(item: item, quantity: quantity)
    end
    redirect_to item_path(item), notice: "#{item.name} has been added to your basket."
  end

  def update
    quantity = basket_item_params[:quantity].to_i
    if @basket_item.update(quantity: quantity)
      redirect_to basket_path, notice: "Quantity updated successfully."
    else
      redirect_to basket_path, alert: "Unable to update quantity."
    end
  end

  def destroy
    @basket_item.destroy
    redirect_to basket_path, notice: "Item has been removed from your basket."
  end

  private

  def set_basket_item
    @basket_item = BasketItem.find(params[:id])
  end

  def basket_item_params
    params.require(:basket_item).permit(:quantity)
  end
end

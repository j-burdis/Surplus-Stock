class BasketItemsController < ApplicationController
  before_action :set_basket_item, only: %i[update destroy]
  def create
    item = Item.find(params[:item_id])
    quantity = params[:quantity].to_i
    Rails.logger.info("Adding item with ID #{item.id} and quantity #{quantity} to basket")

    basket = current_user.basket || Basket.create(user: current_user)
    basket_item = basket.basket_items.find_by(item: item)

    if basket_item
      # Increment the quantity by the value passed from the form
      basket_item.update(quantity: basket_item.quantity + quantity)
    else
      new_basket_item = basket.basket_items.create(item: item, quantity: quantity)

      if new_basket_item.save
        Rails.logger.info("Basket item successfully created: #{new_basket_item.inspect}")
      else
        Rails.logger.error("Basket item failed to save: #{new_basket_item.errors.full_messages}")
      end
    end

    redirect_to basket_path, notice: "#{item.name} has been added to your basket."
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

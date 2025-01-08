class BasketItemsController < ApplicationController
  def create
    item = Item.find(params[:item_id])
    Rails.logger.info("Adding item with ID #{item.id} to basket")
    basket = current_user.basket || Basket.create(user: current_user)

    basket_item = basket.basket_items.find_by(item: item)

    if basket_item
      basket_item.increment!(:quantity)
    else
      new_basket_item = basket.basket_items.create(item: item, quantity: 1)

      if new_basket_item.save
        Rails.logger.info("Basket item successfully created: #{new_basket_item.inspect}")
      else
        Rails.logger.error("Basket item failed to save: #{new_basket_item.errors.full_messages}")
      end
    end

    redirect_to basket_path, notice: "#{item.name} has been added to your basket."
  end

  def destroy
    basket_item = BasketItem.find(params[:id])
    basket_item.destroy
    redirect_to basket_path, notice: "Item has been removed from your basket."
  end
end

class BasketItemsController < ApplicationController
  before_action :set_basket_item, only: %i[update destroy]
  def create
    item = Item.find(params[:item_id])
    quantity = params[:quantity].to_i
    basket = current_user.basket || Basket.create(user: current_user)
    basket_item = basket.basket_items.find_by(item: item)

    if basket_item
      # Calculate new quantity
      new_quantity = basket_item.quantity + quantity
      stock_adjustment = new_quantity - basket_item.quantity
    else
      stock_adjustment = quantity
    end

    if item.stock >= stock_adjustment
      item.decrement!(:stock, stock_adjustment) # Reduce stock
      basket_item ? basket_item.update(quantity: new_quantity) : basket.basket_items.create(item: item, quantity: quantity)
      redirect_to basket_path, notice: "#{item.name} has been added to your basket."
    else
      redirect_to item_path(item), alert: "Not enough stock available."
    end
  end

  def update
    new_quantity = basket_item_params[:quantity].to_i
    stock_adjustment = new_quantity - @basket_item.quantity

    if stock_adjustment.positive? && @basket_item.item.stock >= stock_adjustment
      @basket_item.item.decrement!(:stock, stock_adjustment)
    elsif stock_adjustment.negative?
      @basket_item.item.increment!(:stock, -stock_adjustment)
    end

    if @basket_item.update(quantity: new_quantity)
      redirect_to basket_path, notice: "Quantity updated successfully."
    else
      redirect_to basket_path, alert: "Unable to update quantity."
    end
  end

  def destroy
    # @basket_item.destroy
    # redirect_to basket_path, notice: "Item has been removed from your basket."
    @basket_item.item.increment!(:stock, @basket_item.quantity) # Restore stock
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

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

    respond_to do |format|
      if item.stock >= stock_adjustment
        item.decrement!(:stock, stock_adjustment) # Reduce stock

        if basket_item
          basket_item.update(quantity: new_quantity)
        else
          basket.basket_items.create(item: item, quantity: quantity)
        end

        format.html { redirect_to basket_path, notice: "#{item.name} has been added to your basket." }
        format.json do
          render json: {
            success: true,
            message: "#{item.name} has been added to your basket.",
            flash: {
              type: 'notice', 
              text: "#{item.name} has been added to your basket."
            }
          }
        end
      else
        format.html { redirect_to item_path(item), alert: "Not enough stock available." }
        format.json do
          render json: {
            success: false,
            message: "Not enough stock available.",
            flash: {
              type: 'alert',
              text: "Not enough stock available."
            }
          }
        end
      end
    end
  end

  def update
    new_quantity = basket_item_params[:quantity].to_i
    stock_adjustment = new_quantity - @basket_item.quantity

    respond_to do |format|
      if stock_adjustment.positive? && @basket_item.item.stock >= stock_adjustment
        @basket_item.item.decrement!(:stock, stock_adjustment)
        @basket_item.update(quantity: new_quantity)
        format.html { redirect_to basket_path, notice: "Quantity updated successfully." }
        format.json do
          render json: {
            success: true,
            message: "Quantity updated successfully.",
            flash: {
              type: 'notice',
              text: "Quantity updated successfully"
            }
          }
        end
      elsif stock_adjustment.negative?
        @basket_item.item.increment!(:stock, -stock_adjustment)
        @basket_item.update(quantity: new_quantity)
        format.html { redirect_to basket_path, notice: "Quantity updated successfully." }
        format.json do
          render json: {
            success: true,
            message: "Quantity updated successfully.",
            flash: {
              type: 'notice',
              text: "Quantity updated successfully"
            }
          }
        end
      else
        format.html { redirect_to basket_path, alert: "Unable to update quantity." }
        format.json do
          render json: {
            success: false,
            message: "Unable to update quantity.",
            flash: {
              type: 'alert',
              text: "Unable to update quantity"
            }
          }
        end
      end
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

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
    redirect_to basket_path, notice: "#{item.name} has been added to your basket."
  #   ActiveRecord::Base.transaction do
  #     Rails.logger.info "Starting basket item creation..."
  #     item = Item.find(params[:item_id])
  #     Rails.logger.info "Found item: #{item.id}"
      
  #     unless current_user
  #       Rails.logger.error "No current user found"
  #       raise "User not authenticated"
  #     end
      
  #     basket = current_user.basket || Basket.create!(user: current_user)
  #     Rails.logger.info "Using basket: #{basket.id}"
      
  #     basket_item = basket.basket_items.find_by(item: item)
  #     quantity = params[:quantity].to_i
  #     Rails.logger.info "Quantity to add: #{quantity}"
  
  #     result = if basket_item
  #       Rails.logger.info "Updating existing basket item: #{basket_item.id}"
  #       basket_item.update!(quantity: basket_item.quantity + quantity)
  #     else
  #       Rails.logger.info "Creating new basket item"
  #       new_item = basket.basket_items.create!(item: item, quantity: quantity)
  #       Rails.logger.info "Created basket item with ID: #{new_item.id}"
  #     end
      
  #     Rails.logger.info "Basket item creation completed successfully"
  #   end
    
  #   redirect_to basket_path, notice: "#{item.name} has been added to your basket."
  # rescue ActiveRecord::RecordInvalid => e
  #   Rails.logger.error "Validation error creating basket item: #{e.message}"
  #   Rails.logger.error e.backtrace.join("\n")
  #   redirect_to basket_path, alert: "Could not add item to basket: #{e.message}"
  # rescue => e
  #   Rails.logger.error "Error creating basket item: #{e.message}"
  #   Rails.logger.error e.backtrace.join("\n")
  #   redirect_to basket_path, alert: "Sorry, there was an error adding the item to your basket."
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

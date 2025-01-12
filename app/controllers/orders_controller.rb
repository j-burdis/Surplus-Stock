class OrdersController < ApplicationController
  before_action :set_basket, only: %i[new create]
  def index
  end

  def show
  end

  def new
  end

  def create
    # Create the order
    @order = current_user.orders.create!(
      status: "confirmed",
      order_date: Time.current
    )

    # Transfer basket items to order items
    @basket.basket_items.each do |basket_item|
      @order.order_items.create!(
        item: basket_item.item,
        quantity: basket_item.quantity,
        price: basket_item.item.price
      )
    end

    # Clear the basket
    @basket.basket_items.destroy_all

    # Optional: Save payment details if using Payment model
    Payment.create!(
      order: @order,
      amount: params[:order_total],
      card_type: "Visa", # Placeholder, can be dynamic
      card_last4: "1234", # Placeholder, can extract from card_number
      status: "success"
    )

    # Redirect to a confirmation page
    redirect_to confirmation_order_path(@order), notice: "Order placed successfully!"
  end

  def confirmation
    @order = current_user.orders.find(params[:id])
    # Show the confirmation details (order confirmation page)
  end

  private

  def set_basket
    @basket = current_user.basket
    @basket_items = @basket.basket_items.includes(:item)
  end
end

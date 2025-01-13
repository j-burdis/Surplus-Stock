class OrdersController < ApplicationController
  include OrderCalculations
  before_action :set_basket, only: %i[new create]
  before_action :set_order, only: %i[show confirmation]
  def index
    @orders = current_user.orders.includes(:order_items, :payment)
  end

  def show
  end

  def new
    @order = Order.new
    calculate_totals
  end

  def create
    # Create the order
    @order = current_user.orders.build(status: "pending")

    if @order.save
      # Transfer basket items to order items
      @basket.basket_items.each do |basket_item|
        @order.order_items.create!(
          item: basket_item.item,
          quantity: basket_item.quantity,
          price: basket_item.item.price
        )
      end

      redirect_to new_order_payment_path(@order)
    else
      flash[:alert] = "Could not create order."
      # render :new, status: :unprocessable_entity
      redirect_to basket_path
    end
  end

  def confirmation
    return if @order.paid?

    redirect_to order_path(@order), alert: "Order is not yet paid"
  end

  private

  def set_basket
    @basket = current_user.basket
    @basket_items = @basket.basket_items.includes(:item)
  end

  def set_order
    @order = current_user.orders.find(params[:id])
  end

  # def calculate_totals
  #   @subtotal = @basket_items.sum { |item| item.quantity * item.item.price }
  #   @delivery = 10 # add £10 delivery fee
  #   @total = @subtotal + @delivery
  # end
end

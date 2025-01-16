class OrdersController < ApplicationController
  include OrderCalculations
  before_action :set_basket, only: %i[new create]
  before_action :set_order, only: %i[show confirmation cancel]
  def index
    @orders = current_user.orders.includes(:order_items, :payment)

    @orders = @orders.where(status: params[:status]) if params[:status].present? && Order.statuses.key?(params[:status])

    # Ensure sorting is always applied
    @orders = @orders.order(created_at: :desc)
  end

  def show
  end

  def new
    @order = Order.new
    calculate_totals
  end

  def create
    Order.transaction do
      if @basket_items.empty?
        flash[:alert] = "Your basket is empty"
        redirect_to basket_path and return
      end

      calculate_totals # this sets @total

      current_user.orders.pending.destroy_all

      @order = current_user.orders.build(
        status: "pending",
        total_amount: @total,
        delivery_fee: DELIVERY_FEE
      )
      if @order.save && transfer_basket_to_order(@order)
        redirect_to new_order_payment_path(@order)
      else
        flash[:alert] = "Could not create order."
        redirect_to basket_path
      end
    end
  end

  def confirmation
    return if @order.paid?

    redirect_to order_path(@order), alert: "Order is not yet paid"
  end

  def cancel
    @order.destroy
    flash[:notice] = "Pending order has been cancelled."
    redirect_to basket_path
  end

  private

  def set_basket
    @basket = current_user.basket
    @basket_items = @basket.basket_items.includes(:item)
  end

  def set_order
    @order = current_user.orders.find(params[:id])
  end

  def transfer_basket_to_order(order)
    # Transfer basket items to order items
    @basket.basket_items.each do |basket_item|
      order.order_items.create!(
        item: basket_item.item,
        quantity: basket_item.quantity,
        price: basket_item.item.price
      )
    end
    true
  rescue ActiveRecord::RecordInvalid
    false
  end
end

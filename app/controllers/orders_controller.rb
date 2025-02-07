class OrdersController < ApplicationController
  include OrderCalculations
  before_action :set_basket, only: %i[new create]
  before_action :set_order, only: %i[show confirmation cancel save_address save_delivery_date]
  def index
    @orders = current_user.orders.includes(:order_items, :payment)

    # Remove expired orders
    @orders.each do |order|
      order.destroy if order.expired?
    end

    @orders = @orders.where(status: params[:status]) if params[:status].present? && Order.statuses.key?(params[:status])

    # Ensure sorting is always applied
    @orders = @orders.order(created_at: :desc)
  end

  def show
    render json: { 
      address_complete: @order.address_complete?,
      order: @order 
    }
    @pending_order = @order if @order.status == "pending"
    # Remove expired orders when viewing the order
    return unless @order.expired?

    @order.destroy
    flash[:notice] = "Your order has expired and has been removed."
    redirect_to basket_path
  end

  def new
    @order = Order.new
    calculate_totals
  end

  def create
    Order.transaction do
      @basket.clean_up_expired_items
      @basket_items = @basket.basket_items.includes(:item).reject(&:expired?)

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

  def save_address
    if @order.update(order_params)
      Rails.logger.info "Address saved: #{@order.attributes.slice('house_number', 'street_address', 'city', 'display_postcode')}"
      Rails.logger.info "Address complete?: #{@order.address_complete?}"
      render json: {
        success: true,
        message: "Address saved successfully",
        address_complete: @order.address_complete?
      }
    else
      render json: {
        success: false,
        errors: @order.errors.full_messages
      }, status: :unprocessable_entity
    end
  rescue StandardError
    Rails.logger.error "Error saving address: #{e.message}"
    render json: {
      success: false,
      errors: ["An unexpected error occurred"]
    }, status: :internal_server_error
  end

  def save_delivery_date
    if @order.update(delivery_date: params[:order][:delivery_date])
      render json: {
        success: true,
        message: "Delivery date saved successfully",
        delivery_date: @order.delivery_date.strftime('%Y-%m-%d')
      }
    else
      render json: {
        success: false,
        errors: @order.errors.full_messages
      }, status: :unprocessable_entity
    end
  rescue StandardError
    render json: {
      success: false,
      errors: ["An unexpected error occurred"]
    }, status: :internal_server_error
  end

  def confirmation
    return if @order.paid?

    redirect_to order_path(@order), alert: "Order is not yet paid"
  end

  def cancel
    @order.destroy
    flash[:notice] = "Pending order has been cancelled."

    if request.referer.include?(basket_path) # If user came from the basket page
      redirect_to basket_path
    else # If user came from the order show page or elsewhere
      redirect_to orders_path
    end
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

  def order_params
    params.require(:order).permit(
      :house_number, :street_address, :city, :display_postcode, :delivery_date
    )
  end
end

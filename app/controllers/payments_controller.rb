class PaymentsController < ApplicationController
  include OrderCalculations
  before_action :set_order, except: [:success]
  before_action :check_pending_order, only: [:new, :create]

  def new
    @pending_order = current_user.orders.pending.first
    @payment = @order.build_payment

    # Ensure we have a valid order state
    unless @order&.pending?
      redirect_to basket_path, alert: "Invalid order state"
      return
    end

    # Check if order has expired
    return unless @order.expired?

    @order.destroy
    redirect_to basket_path, alert: "Your order has expired. Please create a new order."
    return
    # If we reach here, render the new payment form
  end

  def create
    ActiveRecord::Base.transaction do
      # @order.update!(order_params) # Save address information to the order
      # Only update address if it's provided in params
      @order.update!(order_params) if order_params.values.any?(&:present?)

      @payment = @order.build_payment(payment_params)

      if check_payment_amount && @payment.save && process_payment
        complete_order
        redirect_to success_order_payments_path(@order)
      else
        flash[:alert] = "Payment failed. Please try again."
        render :new, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    flash[:alert] = e.record.errors.full_messages.join(", ")
    render :new, status: :unprocessable_entity
  end

  def success
    @order = Order.find(params[:order_id])

    unless @order.paid?
      redirect_to order_path(@order), alert: "Order is not paid"
      return
    end

    redirect_to confirmation_order_path(@order)
  end

  private

  def set_order
    @order = current_user.orders.find(params[:order_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to basket_path, alert: "Order not found"
  end

  def order_params
    params.permit(:house_number, :street_address, :city, :display_postcode)
  end

  def payment_params
    params.require(:payment).permit(:card_number, :expiry_date, :cvv, :amount)
  end

  def check_payment_amount
    payment_params[:amount].to_i == @order.total_amount
  end

  def process_payment
    # integrate here with a real payment processor
    # for now simulate a successful payment
    @payment.update(
      status: "completed",
      card_type: Payment.detect_card_type(payment_params[:card_number]),
      card_last4: payment_params[:card_number].last(4)
    )
  end

  def check_pending_order
    return if @order.pending?

    redirect_to basket_path, alert: "Invalid order state"
    false
  end

  def complete_order
    @order.update!(
      status: "paid",
      order_date: Time.current
    )
    clear_basket
  end

  def clear_basket
    current_user.basket.basket_items.destroy_all
  end
end

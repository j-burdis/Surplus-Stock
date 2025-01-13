class PaymentsController < ApplicationController
  include OrderCalculations
  before_action :set_order, except: [:success]

  def new
    @delivery = DELIVERY_FEE
  end

  def create
    @payment = @order.build_payment(payment_params)

    if valid_payment?(payment_params) && @payment.save
      process_payment

      if @payment.success?
        complete_order
        redirect_to success_order_payments_path(@order)
      else
        flash[:alert] = "Payment failed. Please try again."
        render :new, status: :unprocessable_entity
      end
    else
      flash[:alert] = "Invalid payment details."
      redirect_to new_order_path
    end
  end

  def success
    @order = Order.find(params[:order_id])
    redirect_to confirmation_order_path(@order)
  end

  private

  def set_order
    @order = current_user.orders.find(params[:order_id])
  end

  def payment_params
    params.require(:payment).permit(:card_number, :expiry_date, :cvv, :amount)
  end

  def valid_payment?(params)
    card_number = params[:card_number].to_s.delete(" ")
    expiry_date = params[:expiry_date]
    cvv = params[:cvv]
    # Add your regex or validation logic here
    card_number.delete(" ").match?(/\A\d{16}\z/) && # Remove spaces for validation
      expiry_date.match?(%r{\A(0[1-9]|1[0-2])/\d{2}\z}) &&
      cvv.match?(/\A\d{3,4}\z/)
  end

  def process_payment
    # integrate here with a real payment processor
    # for now simulate a successful payment
    @payment.update(
      status: "completed",
      card_type: detect_card_type(payment_params[:card_number]),
      card_last4: payment_params[:card_number].last(4)
    )
  end

  def detect_card_type(number)
    # Basic card type detection - expand as needed
    case number.to_s.first
    when "4" then "Visa"
    when "5" then "MasterCard"
    else "Unknown"
    end
  end

  def complete_order
    @order.update!(
      status: "paid",
      order_date: Time.current
    )
    transfer_basket_to_order
    clear_basket
  end

  def transfer_basket_to_order
    return if @order.order_items.exists?

    basket = current_user.basket
    basket.basket_items.each do |basket_item|
      @order.order_items.create!(
        item: basket_item.item,
        quantity: basket_item.quantity,
        price: basket_item.item.price
      )
    end
  end

  def clear_basket
    current_user.basket.basket_items.destroy_all
  end
end

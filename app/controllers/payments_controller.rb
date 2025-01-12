class PaymentsController < ApplicationController
  def create
    # Validate payment details
    card_number = params[:card_number].to_s.delete(" ")
    expiry_date = params[:expiry_date]
    cvv = params[:cvv]
    order_total = params[:order_total].to_f

    if valid_payment?(card_number, expiry_date, cvv)
      flash[:notice] = "Payment successful!" # Simulate payment success

      # Redirect to OrdersController#create to create the order
      redirect_to orders_path(order_total: order_total)
    else
      flash[:alert] = "Invalid payment details."
      redirect_to new_order_path
    end
  end

  private

  def valid_payment?(card_number, expiry_date, cvv)
    # Add your regex or validation logic here
    card_number.delete(" ").match?(/\A\d{16}\z/) && # Remove spaces for validation
      expiry_date.match?(%r{\A(0[1-9]|1[0-2])/\d{2}\z}) &&
      cvv.match?(/\A\d{3,4}\z/)
  end
end

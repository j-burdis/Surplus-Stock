module OrderCalculations
  extend ActiveSupport::Concern

  DELIVERY_FEE = 10.0

  def calculate_totals
    @subtotal = calculate_subtotal
    @delivery = DELIVERY_FEE
    @total = @subtotal + @delivery
  end

  private

  def calculate_subtotal
    @basket_items.sum { |item| item.quantity * item.item.price }
  end
end

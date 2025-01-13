class Order < ApplicationRecord
  belongs_to :user

  has_many :order_items, dependent: :destroy
  has_one :payment, dependent: :destroy
  has_many :items, through: :order_items

  enum status: {
    pending: "pending",
    paid: "paid",
    processing: "processing",
    shipped: "shipped",
    delivered: "delivered",
    cancelled: "cancelled"
  }

  def paid?
    status == "paid" && payment&.completed?
  end

  def total_amount
    subtotal + OrderCalculations::DELIVERY_FEE
  end

  def subtotal
    order_items.sum { |item| item.quantity * item.price }
  end
end

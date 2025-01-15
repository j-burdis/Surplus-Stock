class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_one :payment, dependent: :destroy
  has_many :items, through: :order_items

  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :delivery_fee, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :recent, -> { order(created_at: :desc) }

  enum status: {
    paid: "paid",
    pending: "pending",
    processing: "processing",
    shipped: "shipped",
    delivered: "delivered",
    cancelled: "cancelled"
  }

  def paid?
    status == "paid" && payment&.completed?
  end
end

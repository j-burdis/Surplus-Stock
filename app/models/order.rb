class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_one :payment, dependent: :destroy
  has_many :items, through: :order_items

  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :delivery_fee, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validates :house_number, :street_address, :city, :display_postcode, presence: true, if: :address_required?

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

  EXPIRATION_PERIOD = 15.minutes

  def expired?
    created_at < Time.current - EXPIRATION_PERIOD && status == "pending"
  end

  def time_left
    [created_at + EXPIRATION_PERIOD - Time.current, 0].max
  end

  def address_complete?
    house_number.present? &&
      street_address.present? &&
      city.present? &&
      display_postcode.present?
  end

  def recently_created?
    return true if created_at.nil?

    created_at >= 1.minute.ago
  end

  def address_required?
    return false if status == "pending" && recently_created?

    true
  end
end

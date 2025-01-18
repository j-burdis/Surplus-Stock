class BasketItem < ApplicationRecord
  belongs_to :basket
  belongs_to :item

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }

  # Virtual attribute for remaining time
  # attr_accessor :remaining_time

  # Check if the basket item has expired
  def expired?
    expiration_time <= Time.current
  end

  # Virtual attribute for remaining time
  def remaining_time
    [expiration_time - Time.current, 0].max
  end

  private

  def expiration_time
    created_at + 1.minutes # Adjust expiration logic as needed
  end
end

class BasketItem < ApplicationRecord
  belongs_to :basket
  belongs_to :item

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }

  # Virtual attribute for remaining time
  # attr_accessor :remaining_time

  # Virtual attribute for remaining time
  def remaining_time
    [30.minutes - (Time.current - created_at), 0].max
  end

  # Check if the basket item has expired
  def expired?
    Time.current > created_at + 30.minutes
  end
end

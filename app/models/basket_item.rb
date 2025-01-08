class BasketItem < ApplicationRecord
  belongs_to :basket
  belongs_to :item
  belongs_to :user

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
end

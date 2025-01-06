class Order < ApplicationRecord
  belongs_to :user

  has_many :order_items, dependent: :destroy
  has_many :items, through: :order_items

  def total_price
    order_items.sum('quantity * price')
  end
end

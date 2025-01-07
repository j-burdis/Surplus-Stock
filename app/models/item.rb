class Item < ApplicationRecord
  belongs_to :user

  has_many :basket_items, dependent: :destroy
  has_many :baskets, through: :basket_items
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end

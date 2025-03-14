class Item < ApplicationRecord
  belongs_to :user

  has_many :basket_items, dependent: :destroy
  has_many :baskets, through: :basket_items
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items
  has_many :wishlist_items, dependent: :destroy
  has_many :wishlists, through: :wishlist_items

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  include PgSearch::Model
  pg_search_scope :search_by_name_and_description,
                  against: { name: 'A', description: 'B' },
                  using: {
                    tsearch: { prefix: true, dictionary: "english" }
                    # trigram: { threshold: 0.1 }
                  }

  def stock_available?(requested_quantity)
    stock >= requested_quantity
  end
end

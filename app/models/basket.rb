class Basket < ApplicationRecord
  belongs_to :user

  has_many :basket_items, dependent: :destroy
  has_many :items, through: :basket_items

  def clean_up_expired_items
    basket_items.includes(:item).each do |basket_item|
      next unless basket_item.expired?

      ActiveRecord::Base.transaction do
        basket_item.item.increment!(:stock, basket_item.quantity)
        basket_item.destroy
      end
    end
  end
end

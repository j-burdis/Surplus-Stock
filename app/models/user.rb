class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :orders, dependent: :destroy
  has_many :basket_items, dependent: :destroy
  has_one :basket, dependent: :destroy
  has_one :wishlist, dependent: :destroy

  def basket
    super || create_basket
  end

  def wishlist
    super || create_wishlist
  end
end

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :orders, dependent: :destroy
  has_one :basket, dependent: :destroy
  has_one :wishlist, dependent: :destroy

  # validates :name, presence: true
  validates :contact_number, format: { with: /\A\d{10,15}\z/, message: "must be a valid number" }, allow_blank: true
  validates :address, length: { maximum: 500 }, allow_blank: true
  validates :postcode,
            format: { with: /\A([A-Z]{1,2}\d[A-Z\d]? ?\d[A-Z]{2})\z/i, message: "must be a valid UK postcode" },
            allow_blank: true

  def basket
    super || create_basket
  end

  def wishlist
    super || create_wishlist
  end
end

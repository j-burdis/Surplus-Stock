class Payment < ApplicationRecord
  belongs_to :order

  # Virtual attributes for transient payment data
  attr_accessor :card_number, :expiry_date, :cvv

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validate :validate_card_details, if: -> { card_number.present? }

  def self.detect_card_type(number)
    # Basic card type detection - expand as needed
    case number.to_s.first
    when "4" then "Visa"
    when "5" then "MasterCard"
    else "Unknown"
    end
  end

  enum status: {
    pending: "pending",
    completed: "completed",
    failed: "failed",
    refunded: "refunded"
  }

  def success?
    status == "completed"
  end

  private

  def validate_card_details
    unless card_number.to_s.delete(" ").match?(/\A\d{16}\z/) &&
           expiry_date.match?(%r{\A(0[1-9]|1[0-2])/\d{2}\z}) &&
           cvv.match?(/\A\d{3,4}\z/)
      errors.add(:base, "Invalid card details")
    end
  end
end

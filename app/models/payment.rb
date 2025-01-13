class Payment < ApplicationRecord
  belongs_to :order

  # Virtual attributes for transient payment data
  attr_accessor :card_number, :expiry_date, :cvv

  enum status: {
    pending: "pending",
    completed: "completed",
    failed: "failed",
    refunded: "refunded"
  }

  def success?
    status == "completed"
  end
end

class CreatePayments < ActiveRecord::Migration[7.2]
  def change
    create_table :payments do |t|
      t.references :order, null: false, foreign_key: true
      t.decimal :amount, null: false
      t.string :card_type
      t.string :card_last4
      t.string :status, default: "pending"

      t.timestamps
    end
  end
end

class ChangeAmountAndPriceToInteger < ActiveRecord::Migration[7.2]
  def change
     change_column :payments, :amount, :integer, using: 'amount::integer'
     change_column :order_items, :price, :integer, using: 'price::integer'
  end
end

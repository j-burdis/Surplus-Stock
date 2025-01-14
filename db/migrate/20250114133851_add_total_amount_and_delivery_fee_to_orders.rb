class AddTotalAmountAndDeliveryFeeToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :total_amount, :integer
    add_column :orders, :delivery_fee, :integer, default: 10

    # Update existing records
    Order.find_each do |order|
      order.update_columns(
        total_amount: order.order_items.sum { |item| item.quantity * item.price },
        delivery_fee: 10
      )
    end

    # Add null constraints
    change_column_null :orders, :total_amount, false
    change_column_null :orders, :delivery_fee, false
  end
end

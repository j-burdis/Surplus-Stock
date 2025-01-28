class AddAddressToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :house_number, :string
    add_column :orders, :street_address, :string
    add_column :orders, :city, :string
    add_column :orders, :display_postcode, :string
  end
end

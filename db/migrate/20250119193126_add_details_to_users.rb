class AddDetailsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :name, :string
    add_column :users, :contact_number, :string
    add_column :users, :address, :text
    add_column :users, :postcode, :string
  end
end

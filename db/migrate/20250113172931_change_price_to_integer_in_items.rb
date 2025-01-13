class ChangePriceToIntegerInItems < ActiveRecord::Migration[7.2]
  def change
    change_column :items, :price, :integer
    change_column :items, :discount_price, :integer
  end
end

class AddCategoryAndDiscountPriceToItems < ActiveRecord::Migration[7.2]
  def change
    add_column :items, :category, :string
    add_column :items, :discount_price, :integer
  end
end

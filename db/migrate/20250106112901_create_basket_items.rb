class CreateBasketItems < ActiveRecord::Migration[7.2]
  def change
    create_table :basket_items do |t|
      t.references :basket, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.integer :quantity
      t.datetime :added_at

      t.timestamps
    end
  end
end

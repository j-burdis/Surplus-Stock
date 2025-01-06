class CreateItems < ActiveRecord::Migration[7.2]
  def change
    create_table :items do |t|
      t.string :name
      t.text :description
      t.decimal :price
      t.string :image_url
      t.integer :quantity
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

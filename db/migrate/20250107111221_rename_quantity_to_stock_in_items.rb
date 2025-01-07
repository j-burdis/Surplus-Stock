class RenameQuantityToStockInItems < ActiveRecord::Migration[7.2]
  def change
    rename_column :items, :quantity, :stock
  end
end

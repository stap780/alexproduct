class AddColumnAvitoIdToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :avito_id, :string
  end
end

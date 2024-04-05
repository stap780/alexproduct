class AddStatusToVariants < ActiveRecord::Migration[7.1]
  def change
    add_column :variants, :status, :string
  end
end

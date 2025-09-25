class AddActiveToAccessKeys < ActiveRecord::Migration[8.0]
  def change
    add_column :access_keys, :active, :boolean
  end
end

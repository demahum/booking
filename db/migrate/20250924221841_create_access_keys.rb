class CreateAccessKeys < ActiveRecord::Migration[8.0]
  def change
    create_table :access_keys do |t|
      t.string :key

      t.timestamps
    end
  end
end

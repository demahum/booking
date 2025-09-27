class AddAccessKeyToDateRanges < ActiveRecord::Migration[8.0]
  def change
    add_reference :date_ranges, :access_key, null: true, foreign_key: true
  end
end

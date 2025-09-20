class CreateDateRanges < ActiveRecord::Migration[8.0]
  def change
    create_table :date_ranges do |t|
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end

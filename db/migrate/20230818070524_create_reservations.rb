class CreateReservations < ActiveRecord::Migration[7.0]
  def change
    create_table :reservations do |t|
      t.datetime :date
      t.integer :hour
      t.integer :minute
      t.string :category
      t.string :name
      t.string :menu
      t.string :dayoff
      t.string :fullhouse
      t.string :phone
      t.string :reservename

      t.timestamps
    end
  end
end

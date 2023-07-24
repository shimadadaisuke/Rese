# 20230719054255_add_columns_to_reservations.rb

class AddColumnsToReservations < ActiveRecord::Migration[7.0]
  def change
    add_column :reservations, :hour, :integer
    add_column :reservations, :minute, :integer
    add_column :reservations, :category, :string
    add_column :reservations, :name, :string
    add_column :reservations, :menu, :string
    add_column :reservations, :dayoff, :string
    add_column :reservations, :fullhouse, :string
  end
  
end

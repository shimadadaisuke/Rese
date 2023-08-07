class AddRserveNameReservations < ActiveRecord::Migration[7.0]
  def change
    add_column :reservations, :reservename, :string
  end
end

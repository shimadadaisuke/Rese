class ReservationsController < ApplicationController
  # ... 他のアクション ...

  def user
    @reservation = Reservation.new
  end

  # ... 他のアクション ...
end

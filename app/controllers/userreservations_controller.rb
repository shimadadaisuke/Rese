class UserreservationsController < ApplicationController

  def user
    @reservation = Reservation.new
  end

end

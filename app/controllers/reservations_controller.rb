class ReservationsController < ApplicationController
  def new
    @reservation = Reservation.new(date: params[:date])
    # 他の処理...
  end

  def create
    @reservation = Reservation.new(reservation_params)

    if @reservation.save
      redirect_to calendars_path, notice: '予約が作成されました。'
    else
      set_calendar_variables
      render :index
    end
  end

  def destroy
    reservation = Reservation.find_by(date: params[:date], hour: params[:hour], minute: params[:minute], name: params[:name])

    if reservation
      reservation.destroy
      redirect_to calendars_path, notice: '予約を削除しました。'
    else
      redirect_to calendars_path, alert: '予約が見つかりませんでした。'
    end
  end
  
  

  private

  def reservation_params
    params.require(:reservation).permit(:date, :category, :hour, :minute, :name, :menu, :dayoff, :fullhouse)
  end

  def set_calendar_variables
    @current_month = Date.today.at_beginning_of_month
    @weeks = generate_calendar_weeks(@current_month)
  end

  def generate_calendar_weeks(month)
    start_date = month.at_beginning_of_month
    end_date = month.at_end_of_month

    weeks = []
    current_date = start_date.beginning_of_week(:sunday).to_datetime

    while current_date <= end_date do
      week = []
      7.times do
        if current_date.month == month.month
          date = current_date.to_date
          reservations = Reservation.where(date: date)
          week << { date: date, reservations: reservations, holidays: japanese_holidays(date) }
        else
          week << nil
        end
        current_date += 1.day
      end
      weeks << week
    end

    weeks
  end

  def japanese_holidays(date)
    holidays = Holidays.on(date, :jp)
    holidays.map { |holiday| holiday[:name] }
  end
end

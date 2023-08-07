require 'date'
require 'holidays'

class CalendarsController < ApplicationController
  include CalendarsHelper

  def index
    selected_month = params[:month]
    if selected_month.present?
      @current_month = Date.parse("01-#{selected_month}-#{Date.today.year}")
    else
      @current_month = Date.today.at_beginning_of_month
    end
    
    @weeks = generate_calendar_weeks(@current_month)
    @reservations = Reservation.where(date: @current_month.at_beginning_of_month.beginning_of_day..@current_month.at_end_of_month.end_of_day)
    @reservations_by_date = @reservations.group_by { |r| r.date.to_date }
    @reservation = Reservation.new
  end
  
  def create
    @reservation = Reservation.new(reservation_params)

    if @reservation.save
      redirect_to calendars_path(month: @reservation.date.next_month.strftime("%m")), notice: "予約が作成されました。"
    else
      @current_month = Date.today.at_beginning_of_month
      @weeks = generate_calendar_weeks(@current_month)
      render :index
    end
  end

  private

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

  def reservation_params
    params.require(:reservation).permit(:date, :hour, :minute, :name, :menu)
  end
end

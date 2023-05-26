require 'date'
require 'holidays'

class CalendarsController < ApplicationController
  def index
    @events = Calendar.all
    @current_month = params[:month] ? Date.parse("01-#{params[:month]}-#{Date.today.year}") : Date.today.at_beginning_of_month

    @weeks = []
    start_date = @current_month.at_beginning_of_month
    end_date = @current_month.at_end_of_month
    current_date = start_date.beginning_of_week(:sunday)

    while current_date <= end_date do
      week = []
      7.times do
        if current_date.month == @current_month.month
          week << { date: current_date, events: generate_time_slots(current_date), holidays: japanese_holidays(current_date) }
        else
          week << nil
        end
        current_date += 1.day
      end
      @weeks << week
    end
  end

  helper_method :weekend_or_holiday?

  private

  def generate_time_slots(date)
    return [] if weekend_or_holiday?(date)

    time_slots = []
    if date.month == @current_month.month
      (9..15).step(2) do |hour|
        time_slots << { start_time: "#{hour}:00", end_time: "#{hour + 2}:00" }
      end
    end
    time_slots
  end

  def weekend_or_holiday?(date)
    date.saturday? || date.sunday? || japanese_holidays(date).any?
  end

  def japanese_holidays(date)
    holidays = Holidays.on(date, :jp)
    holidays.map { |holiday| holiday[:name] }
  end
end

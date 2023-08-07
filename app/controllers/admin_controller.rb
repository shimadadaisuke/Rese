class AdminController < ApplicationController
  require 'date'
  require 'holidays'
  
  def index
    selected_month = params[:month]
    if selected_month.present?
      @current_month = Date.parse("01-#{selected_month}-#{Date.today.year}")
    else
      @current_month = Date.today.at_beginning_of_month
    end
  
    @weeks = generate_calendar_weeks(@current_month)
    @reservations = Reservation.where.not(date: nil)
    @reservations_by_date = @reservations.group_by { |r| r.date.to_date }
    @reservation = Reservation.new
    
    respond_to do |format|
      format.html
      format.json do
        render json: @reservations
      end
    end
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
    

        def reservations
    name = params[:name]
    reservations = Reservation.where(name: name).as_json
    render json: reservations
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
    
      def weekend_or_holiday?(date)
        date.monday? || date.sunday? || japanese_holidays(date).any?
      end
    
      def japanese_holidays(date)
        holidays = Holidays.on(date, :jp)
        holidays.map { |holiday| holiday[:name] }
      end
    
      def reservation_params
        params.require(:reservation).permit(:date, :hour, :minute, :name, :menu)
      end

 


      
    end

    
    
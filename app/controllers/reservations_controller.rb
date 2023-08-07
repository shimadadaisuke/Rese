class ReservationsController < ApplicationController
  before_action :set_calendar_variables, only: [:new, :create, :index]

  def index
    @reservations = Reservation.all
  end
  
  def new
    @reservation = Reservation.new(date: params[:date])
    # 他の処理...
  end

  def create
    @reservation = Reservation.new(reservation_params)
  
    if @reservation.category == '空き枠登録'
      @reservation.name = '空き'
    elsif @reservation.category == '予定変更'
      @reservation.name = '満員' if @reservation.fullhouse == 'ON'
      @reservation.name = '臨時休暇' if @reservation.dayoff == 'ON'
    end
  
    if @reservation.save
      # 保存が成功した後に古いデータを削除する
      delete_old_data
      redirect_to admin_path(month: @reservation.date.strftime("%Y-%m"))
    else
      redirect_to new_reservation_path, alert: "何度やっても同じであれば、サーバ先の故障か改修が必要"
    end
  end
    
  def user
    @reservation = Reservation.new(
      date: params[:date],
      hour: params[:hour],
      minute: params[:minute]
    )
  end
  
  def destroy
    reservation = Reservation.find(params[:id])
    reservation.destroy
    head :no_content
  end


  def create_user_reservation
    @reservation = Reservation.new(reservation_params)
    
    # 指定された日時の"空き"という名前の予約を探します
    existing_reservation = Reservation.find_by(date: @reservation.date, hour: @reservation.hour, minute: @reservation.minute, name: '空き')
    if existing_reservation
      existing_reservation.update(name: 'ご予約受付中', reservename: @reservation.reservename, phone: @reservation.phone, menu: @reservation.menu)
      flash[:notice] = "ご予約を受け付けました、改めてご連絡いたします。\n数日経過してもご連絡が無い場合は、\nお手数ですが、ご一報いただけますと幸いです。"
      redirect_to calendars_path and return
    end

    if @reservation.save
      # 保存が成功した後に古いデータを削除する
      delete_old_data
      redirect_to calendars_path(month: @reservation.date.strftime("%Y-%m"))
    else
      redirect_to new_reservation_path, alert: "何度やっても同じであれば、サーバ先の故障か改修が必要"
    end

    def copy_reservename_to_name
      @reservation = Reservation.find(params[:id])
      if @reservation
        @reservation.update(name: @reservation.reservename)
        render json: { message: 'Updated successfully.' }, status: :ok
      else
        render json: { error: 'Reservation not found.' }, status: :not_found
      end
    end
  end
    
  def copy_reservename_to_name
    @reservation = Reservation.find(params[:id])
    if @reservation
      @reservation.update(name: @reservation.reservename)
      render json: { message: 'Updated successfully.' }, status: :ok
    else
      render json: { error: 'Reservation not found.' }, status: :not_found
    end
  end

  private

  def delete_old_data
    five_months_ago = 5.months.ago.beginning_of_month
    five_months_later = 5.months.from_now.end_of_month
  
    # 例：Reservationモデルの場合
    Reservation.where("date < ? OR date > ?", five_months_ago, five_months_later).delete_all
  end

  def reservation_params
    params.require(:reservation).permit(:date, :category, :hour, :minute, :name, :menu, :dayoff, :fullhouse, :reservename, :phone)
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

require 'date'
require 'holidays'

class CalendarsController < ApplicationController
  include CalendarsHelper

  # カレンダーのトップページ
  def index
    # 選択された月を取得。なければ今月の初日を設定
    selected_month = params[:month]
    @current_month = selected_month.present? ? Date.parse("01-#{selected_month}-#{Date.today.year}") : Date.today.at_beginning_of_month

    # カレンダー用の週データを生成
    @weeks = generate_calendar_weeks(@current_month)

    # 今月の予約を取得
    @reservations = Reservation.where(date: @current_month.at_beginning_of_month.beginning_of_day..@current_month.at_end_of_month.end_of_day)

    # 予約を日付ごとにグループ化
    @reservations_by_date = @reservations.group_by { |r| r.date.to_date }

    # 新しい予約オブジェクトを作成
    @reservation = Reservation.new
  end

  # 予約の作成
  def create
    @reservation = Reservation.new(reservation_params)
    if @reservation.save
      # 保存成功時は次の月へリダイレクト
      redirect_to calendars_path(month: @reservation.date.next_month.strftime("%m")), notice: "予約が作成されました。"
    else
      # 保存失敗時は今月のカレンダー再生成
      @current_month = Date.today.at_beginning_of_month
      @weeks = generate_calendar_weeks(@current_month)
      render :index
    end
  end

  private

  # カレンダーの週データを生成するプライベートメソッド
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
          # 週のデータに日付、予約、祝日情報を追加
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

  # 日本の祝日を取得するプライベートメソッド
  def japanese_holidays(date)
    holidays = Holidays.on(date, :jp)
    holidays.map { |holiday| holiday[:name] }
  end

  # 予約パラメータを取得するプライベートメソッド
  def reservation_params
    params.require(:reservation).permit(:date, :hour, :minute, :name, :menu)
  end
end

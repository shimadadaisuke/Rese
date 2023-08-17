class AdminController < ApplicationController
  # 日付と祝日関連のライブラリを読み込む
  require 'date'
  require 'holidays'
  
  # 管理者認証
  before_action :authenticate

  # 管理画面のトップページ
  def index
    # 選択された月を取得
    selected_month = params[:month]
    # 選択された月があればその月の初日を、なければ今月の初日を設定
    @current_month = selected_month.present? ? Date.parse("01-#{selected_month}-#{Date.today.year}") : Date.today.at_beginning_of_month
    # カレンダー用の週データを生成
    @weeks = generate_calendar_weeks(@current_month)
    # 日付が設定されている予約を取得
    @reservations = Reservation.where.not(date: nil)
    # 予約を日付ごとにグループ化
    @reservations_by_date = @reservations.group_by { |r| r.date.to_date }
    # 新しい予約オブジェクトを作成
    @reservation = Reservation.new

    # 応答フォーマットをHTMLとJSONに対応
    respond_to do |format|
      format.html
      format.json { render json: @reservations }
    end
  end

  # 予約の作成
  def create
    # 予約の新規作成
    @reservation = Reservation.new(reservation_params)

    # 予約の保存に成功した場合
    if @reservation.save
      redirect_to calendars_path(month: @reservation.date.next_month.strftime("%m")), notice: "予約が作成されました。"
    else
      # 保存に失敗した場合、今月のカレンダーを再生成
      @current_month = Date.today.at_beginning_of_month
      @weeks = generate_calendar_weeks(@current_month)
      render :index
    end
  end

  # 指定した名前の予約情報をJSONで返す
  def reservations
    render json: Reservation.where(name: params[:name]).as_json
  end

  # 予約情報のコピー
  def copy_reservations
    # コピー元の日付を取得
    source_date_time = DateTime.parse(params[:source_date] + " 00:00:00 UTC")
    # コピー先の日付を取得
    destination_dates = params[:destination_dates].map { |date| Date.parse(date) }
    # コピー元の予約を取得
    reservations_to_copy = Reservation.where(date: source_date_time)

    # 各コピー先の日付に対して予約をコピー
    destination_dates.each do |destination_date|
      reservations_to_copy.each do |reservation|
        new_reservation = reservation.dup
        new_reservation.date = destination_date
        new_reservation.save!
      end
    end

    redirect_to admin_path(month: params[:source_date].to_date.strftime("%Y-%m"))

  end

  private

  # Basic認証の設定
  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == Rails.application.credentials.admin[:username] && password == Rails.application.credentials.admin[:password]
    end
  end

  # カレンダーの週データを生成
  def generate_calendar_weeks(month)
    # 月の初日と最終日を取得
    start_date = month.at_beginning_of_month
    end_date = month.at_end_of_month

    weeks = []
    # 週の最初の日付（日曜日）から開始
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

  # 週末または祝日か判定
  def weekend_or_holiday?(date)
    date.monday? || date.sunday? || japanese_holidays(date).any?
  end

  # 日本の祝日を取得
  def japanese_holidays(date)
    holidays = Holidays.on(date, :jp)
    holidays.map { |holiday| holiday[:name] }
  end

  # 予約パラメータを取得
  def reservation_params
    params.require(:reservation).permit(:date, :hour, :minute, :name, :menu)
  end
end

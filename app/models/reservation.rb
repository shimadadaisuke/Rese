class Reservation < ApplicationRecord
  
    def reservation_category?
      category == '予約登録'
    end
  end
  
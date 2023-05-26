module CalendarsHelper
    def weekend_or_holiday?(date)
      date.saturday? || date.sunday? || japanese_holiday?(date)
    end
  
    def japanese_holiday?(date)
      holidays = Holidays.on(date, :jp)
      holidays.any?
    end
  end
  
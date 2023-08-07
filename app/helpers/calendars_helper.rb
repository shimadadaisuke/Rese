module CalendarsHelper
  def weekend_or_holiday?(date)
    date.monday? || date.sunday? || japanese_holiday?(date)
  end

  def japanese_holiday?(date)
    holidays = Holidays.on(date, :jp)
    holidays.any?
  end

  def link_or_text(reservation)
    if reservation.name == '空き'
      if reservation.hour.present? && reservation.minute.present?
        link_to "#{reservation.hour}:#{reservation.minute} #{reservation.name} #{reservation.menu}", '#', class: 'reservation-link'
      else
        link_to "#{reservation.name} #{reservation.menu}", '#', class: 'reservation-link'
      end
    else
      if reservation.hour.present? && reservation.minute.present?
        "#{reservation.hour}:#{reservation.minute} #{reservation.name} #{reservation.menu}"
      else
        "#{reservation.name} #{reservation.menu}"
      end
    end
  end
end

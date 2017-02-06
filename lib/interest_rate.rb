require 'date'

class InterestRate
    def initialize
        @default_rate = 0.0
        @rates = {}
        @current_date = nil
        @most_recent_date = Date.parse("01/1970")
        @most_recent_rate = 0.0
    end

    def get_rate date: nil
        rate = nil

        if date
            rate = get_rate_from_series_or_last_rate date
        end

        if not rate and @current_date
            rate = get_rate_from_series_or_last_rate @current_date
        end

        if not rate
            rate = @default_rate
        end

        rate
    end

    def set_rate rate, date
        date_ = Date.parse(date)

        if date_ > @most_recent_date
            @most_recent_date = date_
            @most_recent_rate = rate
        end

        @rates[date] = rate
    end

    def set_rates rates
        rates.each do |date, rate|
            set_rate rate, date
        end
    end

    def set_begin date
        @current_date = date
    end

    def next
        date = Date.parse(@current_date)
        date = date.advance months: 1
        @current_date = date.strftime "%m/%Y"
    end

    private

    def get_rate_from_series_or_last_rate date
        if Date.parse(date) < @most_recent_date
            rate = @rates[date]
        else
            rate = @most_recent_rate
        end
    end
end
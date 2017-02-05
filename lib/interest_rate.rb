require 'date'

class InterestRate
    def initialize
        @default_rate = 0.0
        @rates = {}
        @current_date = nil
    end

    def get_rate date: nil
        if date != nil and @rates[date] != nil
            @rates[date]
        elsif @current_date != nil and @rates[@current_date] != nil
            @rates[@current_date]
        else
            @default_rate
        end
    end

    def load_rate rate, date
        @rates[date] = rate
    end

    def load_rates rates
        rates.each do |date, rate|
            load_rate rate, date
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
end
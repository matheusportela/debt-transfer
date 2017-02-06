class Debt
    def initialize debt
        @debt = debt
    end

    def is_payed?
        @debt == 0.00
    end

    def debt
        @debt.round(2)
    end

    def apply_interest interest, months: 1
        months.times do
            @debt *= 1 + interest
        end
    end

    def apply_interest_series interest_rates
        interest_rates.each do |i|
            apply_interest i
        end
    end

    def pay payment
        if payment < @debt
            payed = payment
            @debt -= payment
        else
            payed = @debt
            @debt = 0.00
        end

        payed.round(2)
    end

    def pay_with_fixed_interest payment, interest, months: 1
        payed = 0.00

        months.times do
            payed += pay payment
            apply_interest interest
        end

        payed.round(2)
    end

    def pay_with_variable_interest payment, interest_rates
        payed = 0.00

        interest_rates.each do |i|
            payed += pay payment
            apply_interest i
        end

        payed.round(2)
    end

    def pay_entire_debt_with_fixed_interest payment, interest
        payed = 0.00

        until is_payed?
            payed += pay_with_fixed_interest payment, interest
        end

        payed.round(2)
    end

    def pay_entire_debt_with_variable_interest payment, interest_rates
        payed = 0.00

        until is_payed?
            interest = interest_rates.shift
            payed += pay_with_fixed_interest payment, interest
        end

        payed.round(2)
    end
end
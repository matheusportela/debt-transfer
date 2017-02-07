require 'csv'
require_relative '../lib/debt'
require_relative '../lib/interest_rate'

class DebtSimulator
    def initialize
        @max_months = 120
        @headers = {
            :revolving_credit_card => '22022 - Average interest rate of nonearmarked new credit operations - Households - Credit card revolving credit - % p.y.',
            :installment_credit_card => '22023 - Average interest rate of nonearmarked new credit operations - Households - Credit card financing - % p.y.',
            :payday_loan => '20747 - Average interest rate of nonearmarked new credit operations - Households - Payroll-deducted personal loans - Total - % p.y.',
            :check => '20741 - Average interest rate of nonearmarked new credit operations - Households - Overdraft - % p.y.'
        }
        @interest_rates = {}
        load_interest_rates "public/interest_rates.csv"
    end

    def debt_types
        @headers.keys
    end

    def is_valid? debt_type
        @headers.keys.include?(debt_type)
    end

    def load_interest_rates file
        @headers.keys.each do |key|
            @interest_rates[key] = InterestRate.new
        end

        CSV.foreach(file, headers: true, col_sep: ';', converters: :numeric) do |row|
            date = row["Date"]

            # Ignore last line of CSV file, which only states the source for
            # the given interest rates
            if date != "Source"
                @headers.keys.each do |key|
                    @interest_rates[key].set_rate convert_to_monthly_interest_rate(row[@headers[key]]), date
                end
            end
        end
    end

    def convert_to_monthly_interest_rate(interest_rate)
        (interest_rate / (12 * 100.00)).round(4)
    end

    def get_interest_rate debt_type, date
        @interest_rates[debt_type].get_rate date: date
    end

    def simulate_debt debt_type, initial_debt, initial_date, monthly_payment
        debt = Debt.new initial_debt
        interest_rates = @interest_rates[debt_type]
        interest_rates.set_begin initial_date
        payed = 0.00
        months = 0

        while not debt.is_payed? and months < @max_months
            payed += debt.pay monthly_payment
            debt.apply_interest interest_rates.get_rate

            if debt_type != :payday_loan
                interest_rates.next
            end

            months += 1

            if months == @max_months
                payed = Float::INFINITY
            end
        end

        payed.round(2)
    end
end
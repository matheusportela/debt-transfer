require 'csv'

class DebtTransferController < ApplicationController
    def initialize
        @interest_rates = CSV.read("app/assets/interest_rates.csv",
            col_sep: ';', converters: :numeric)
        @debt_modality_index = {
            :check => 1,
            :payday_loan => 2,
            :overdue_credit_card => 3,
            :credit_card => 4
        }
    end

    def calculate_total_debt(debt: nil, months: nil, monthly_interest: nil)
        (debt*((1 + monthly_interest)**months)).round(2)
    end

    def calculate_total_debt_with_payments(debt: nil, monthly_payment: nil,
                                           monthly_interest: nil)
        total = 0.0

        while debt != 0 and debt != Float::INFINITY
            if monthly_payment < debt
                total += monthly_payment
                debt -= monthly_payment
                debt *= 1 + monthly_interest
            else
                total += debt
                debt = 0
            end
        end

        if debt == Float::INFINITY
            total = Float::INFINITY
        end

        total.round(2)
    end

    def get_interest(debt_modality: nil, date: nil)
        @interest_rates.each do |row|
            if date == row[0]
                year_interest_rate = row[@debt_modality_index[debt_modality]] / 100.0
                monthly_interest_rate = convert_year_to_monthly_interest_rate year_interest_rate
                return monthly_interest_rate.round(4)
            end
        end

        nil
    end

    def convert_year_to_monthly_interest_rate(interest_rate)
        interest_rate / 12.0
    end

    def calculate_debt(debt: nil, due_date: nil, minimum_charge: nil,
            debt_modality: nil)
        monthly_interest = get_interest(debt_modality: debt_modality,
            date: due_date)
        calculate_total_debt_with_payments(debt: debt,
            monthly_payment: minimum_charge,
            monthly_interest: monthly_interest)
    end

    def calculate_credit_card_debt(debt: nil, due_date: nil,
            minimum_charge: nil)
        calculate_debt(debt: debt, due_date: due_date,
            minimum_charge: minimum_charge, debt_modality: :credit_card)
    end

    def calculate_overdue_credit_card_debt(debt: nil, due_date: nil,
            minimum_charge: nil)
        calculate_debt(debt: debt, due_date: due_date,
            minimum_charge: minimum_charge,
            debt_modality: :overdue_credit_card)
    end

    def calculate_check_debt(debt: nil, due_date: nil,
            minimum_charge: nil)
        calculate_debt(debt: debt, due_date: due_date,
            minimum_charge: minimum_charge,
            debt_modality: :check)
    end

    def calculate_payday_loan_debt(debt: nil, due_date: nil,
            minimum_charge: nil)
        calculate_debt(debt: debt, due_date: due_date,
            minimum_charge: minimum_charge,
            debt_modality: :payday_loan)
    end

    def home
        render :home
    end

    def result
        @credit_card_debt = calculate_credit_card_debt(
            debt: params[:invoice_value].to_f,
            due_date: params[:invoice_due_date],
            minimum_charge: params[:minimum_charge].to_f)
        @overdue_credit_card_debt = calculate_overdue_credit_card_debt(
            debt: params[:invoice_value].to_f,
            due_date: params[:invoice_due_date],
            minimum_charge: params[:minimum_charge].to_f)
        @check_debt = calculate_check_debt(
            debt: params[:invoice_value].to_f,
            due_date: params[:invoice_due_date],
            minimum_charge: params[:minimum_charge].to_f)
        @payday_loan_debt = calculate_payday_loan_debt(
            debt: params[:invoice_value].to_f,
            due_date: params[:invoice_due_date],
            minimum_charge: params[:minimum_charge].to_f)
        render :result
    end
end

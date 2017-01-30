class DebtTransferController < ApplicationController
    def initialize
        @debt_modalities = {
            :credit_card => { :monthly_interest => 0.1 },
            :check => { :monthly_interest => 0.05 },
            :payday_loan => { :monthly_interest => 0.01 }
        }
    end

    def debt_modalities
        @debt_modalities
    end

    def calculate_total_debt(debt: nil, months: nil, monthly_interest: nil)
        (debt*((1 + monthly_interest)**months)).round(2)
    end

    def calculate_total_debt_with_payments(debt: nil, monthly_payment: nil,
                                           monthly_interest: nil)
        total = 0.0

        while debt != 0
            if monthly_payment < debt
                total += monthly_payment
                debt -= monthly_payment
                debt *= 1 + monthly_interest
            else
                total += debt
                debt = 0
            end
        end

        total.round(2)
    end

    def simulate_debt(debt: nil, monthly_payment: nil, debt_modality: nil)
        monthly_interest = @debt_modalities[debt_modality][:monthly_interest]
        calculate_total_debt_with_payments(
            debt: debt, monthly_payment: monthly_payment,
            monthly_interest: monthly_interest)
    end

    def find_best_debt(debt: nil, monthly_payment: nil)
        debts = Array.new

        @debt_modalities.each do |debt_modality, debt_parameters|
            puts "Debt: #{debt}"
            simulated_debt = simulate_debt(
                debt: debt, monthly_payment: monthly_payment,
                debt_modality: debt_modality)
            debts << {
                :debt => simulated_debt,
                :debt_modality => debt_modality
            }
        end

        minimum_debt = debts.min do |a, b|
            a[:debt] <=> b[:debt]
        end

        minimum_debt
    end

    def home
        render :home
    end

    def simulate
        @best_debt = find_best_debt(debt: params[:invoice_value].to_f,
            monthly_payment: params[:minimum_charge].to_f)
        render :simulate
    end
end

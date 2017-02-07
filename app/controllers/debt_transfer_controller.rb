require 'debt_simulator'

class DebtTransferController < ApplicationController
    def initialize
        @debt_simulator = DebtSimulator.new
    end

    def home
        render :home
    end

    def result
        @debts = {}

        @debt_simulator.debt_types.each do |debt_type|
            @debts[debt_type] = @debt_simulator.simulate_debt(
                debt_type,
                params[:invoice_value].to_f,
                params[:invoice_due_date],
                params[:minimum_charge].to_f)
        end

        render :result
    end
end

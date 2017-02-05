require_relative '../lib/debt'

class DebtTest < ActiveSupport::TestCase
    test "should initialize debt with given value" do
        debt = Debt.new 100.00
        assert_equal 100.00, debt.debt
    end

    test "should increase debt after applying interest" do
        debt = Debt.new 100.00

        debt.apply_interest 0.1
        assert_equal 110.00, debt.debt

        debt.apply_interest 0.1
        assert_equal 121.00, debt.debt

        debt.apply_interest 0.2
        assert_equal 145.20, debt.debt
    end

    test "should apply interest for multiple months" do
        debt = Debt.new 100.00

        debt.apply_interest 0.1, months: 2
        assert_equal 121.00, debt.debt

        debt.apply_interest 0.2, months: 2
        assert_equal 174.24, debt.debt
    end

    test "should apply interest series" do
        debt = Debt.new 100.00

        debt.apply_interest_series [0.1, 0.05, 0.15, 0.1]
        assert_equal 146.11, debt.debt
    end

    test "should decrease debt after paying it" do
        debt = Debt.new 100.00

        debt.pay 50.00
        assert_equal 50.00, debt.debt

        debt.pay 70.00
        assert_equal 0.00, debt.debt
    end

    test "should return payed amount" do
        debt = Debt.new 100.00

        payed = debt.pay 50.00
        assert_equal 50.00, payed

        payed = debt.pay 70.00
        assert_equal 50.00, payed
    end

    test "should pay and apply interest" do
        debt = Debt.new 100.00

        debt.pay_with_fixed_interest 10.00, 0.1
        assert_equal 99.00, debt.debt

        debt.pay_with_fixed_interest 50.00, 0.2
        assert_equal 58.80, debt.debt
    end

    test "should pay recurrently with fixed interest" do
        debt = Debt.new 100.00

        payed = debt.pay_with_fixed_interest 10.00, 0.1, months: 3
        assert_equal 96.69, debt.debt
        assert_equal 30.00, payed
    end

    test "should pay recurrently with variable interest" do
        interest_rates = [0.1, 0.05, 0.15, 0.1]
        debt = Debt.new 100.00

        payed = debt.pay_with_variable_interest 10.00, interest_rates
        assert_equal 94.56, debt.debt
        assert_equal 40.00, payed
    end

    test "should pay entire debt with fixed interest" do
        debt = Debt.new 100.00

        payed = debt.pay_entire_debt_with_fixed_interest 10.00, 0.1
        assert_equal 0.00, debt.debt
        assert_equal 251.65, payed
    end

    test "should pay entire debt with variable interest" do
        debt = Debt.new 100.00
        interest_rates = [
            0.05, 0.01, 0.03, 0.04, 0.02, 0.01, 0.01, 0.05, 0.09, 0.02, 0.07,
            0.06, 0.03, 0.02, 0.05, 0.06, 0.02, 0.01
        ]

        payed = debt.pay_entire_debt_with_variable_interest 10.00, interest_rates
        assert_equal 0.00, debt.debt
        assert_equal 117.02, payed
    end
end
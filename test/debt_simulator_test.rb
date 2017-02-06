require_relative '../lib/debt_simulator'

class DebtSimulatorTest < ActiveSupport::TestCase
    test "should have three different types of debt" do
        simulator = DebtSimulator.new
        assert_equal true, simulator.is_valid?(:revolving_credit_card)
        assert_equal true, simulator.is_valid?(:installment_credit_card)
        assert_equal true, simulator.is_valid?(:payday_loan)
        assert_equal true, simulator.is_valid?(:check)
        assert_equal false, simulator.is_valid?(:mortgage)
        assert_equal false, simulator.is_valid?(:secured_loan)
    end

    test "should load interest rates from CSV file" do
        simulator = DebtSimulator.new
        assert_equal 0.2689, simulator.get_interest_rate(
            :revolving_credit_card, "01/2012")
        assert_equal 0.3662, simulator.get_interest_rate(
            :revolving_credit_card, "01/2016")
        assert_equal 0.0883, simulator.get_interest_rate(
            :installment_credit_card, "06/2013")
        assert_equal 0.0997, simulator.get_interest_rate(
            :installment_credit_card, "06/2015")
        assert_equal 0.0245, simulator.get_interest_rate(
            :payday_loan, "06/2016")
        assert_equal 0.0244, simulator.get_interest_rate(
            :payday_loan, "12/2016")
        assert_equal 0.1741, simulator.get_interest_rate(:check, "01/2015")
        assert_equal 0.1368, simulator.get_interest_rate(:check, "03/2011")
    end

    test "should simulate revolving credit card debt" do
        debt_type = :revolving_credit_card
        simulator = DebtSimulator.new debt_type: debt_type
        total = simulator.simulate_debt debt_type, 100.00, "01/2016", 50.00
        assert_equal 125.08, total
    end

    test "should simulate installment credit card debt" do
        debt_type = :installment_credit_card
        simulator = DebtSimulator.new debt_type: debt_type
        total = simulator.simulate_debt debt_type, 100.00, "01/2016", 50.00
        assert_equal 106.75, total
    end

    test "should simulate check debt" do
        debt_type = :check
        simulator = DebtSimulator.new debt_type: debt_type
        total = simulator.simulate_debt debt_type, 100.00, "01/2016", 50.00
        assert_equal 115.16, total
    end

    test "should simulate payday loan debt with fixed interest" do
        debt_type = :payday_loan
        simulator = DebtSimulator.new debt_type: debt_type
        total = simulator.simulate_debt debt_type, 1000.00, "03/2011", 50.00
        assert_equal 1339.88, total
    end

    test "should return infinity when debt cannot be payed in 120 months" do
        debt_type = :revolving_credit_card
        simulator = DebtSimulator.new debt_type: debt_type

        total = simulator.simulate_debt debt_type, 1000.00, "03/2011", 195.32
        assert_equal Float::INFINITY, total

        total = simulator.simulate_debt debt_type, 1000.00, "03/2011", 100.00
        assert_equal Float::INFINITY, total

        total = simulator.simulate_debt debt_type, 1000.00, "03/2011", 200.00
        assert total < Float::INFINITY
    end
end
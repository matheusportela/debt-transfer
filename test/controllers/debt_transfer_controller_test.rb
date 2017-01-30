require 'test_helper'

class DebtTransferControllerTest < ActionDispatch::IntegrationTest
  test "should get root" do
    get root_url
    assert_response :success
  end

  test "should have three debt modalities" do
    controller = DebtTransferController.new
    assert_equal 3, controller.debt_modalities.length
  end

  test "should have debt modalities details" do
    controller = DebtTransferController.new

    controller.debt_modalities.each do |modality_name, debt_modality|
        assert_in_delta 0.5, debt_modality[:monthly_interest], 0.5
    end
  end

  test "should calculate total debt for one month" do
    controller = DebtTransferController.new
    assert_equal 110.00, controller.calculate_total_debt(debt: 100, months: 1,
                                                         monthly_interest: 0.1)
  end

  test "should calculate total debt for 12 months" do
    controller = DebtTransferController.new
    assert_equal 313.84, controller.calculate_total_debt(debt: 100, months: 12,
                                                         monthly_interest: 0.1)
  end

  test "should calculate total debt with payments" do
    controller = DebtTransferController.new
    assert_equal 105.50, controller.calculate_total_debt_with_payments(
        debt: 100, monthly_payment: 50, monthly_interest: 0.1)
  end

  test "should simulate total debt with different debt modalities" do
    controller = DebtTransferController.new
    assert_equal 105.50, controller.simulate_debt(
        debt: 100, monthly_payment: 50, debt_modality: :credit_card)
    assert_equal 102.63, controller.simulate_debt(
        debt: 100, monthly_payment: 50, debt_modality: :check)
    assert_equal 100.51, controller.simulate_debt(
        debt: 100, monthly_payment: 50, debt_modality: :payday_loan)
  end

  test "should find best debt modality" do
    controller = DebtTransferController.new
    assert_equal :payday_loan, controller.find_best_debt(debt: 100,
        monthly_payment: 50)[:debt_modality]
  end
end

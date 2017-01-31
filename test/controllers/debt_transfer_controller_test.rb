require 'test_helper'

class DebtTransferControllerTest < ActionDispatch::IntegrationTest
  test "should get root" do
    get root_url
    assert_response :success
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

  test "should get interest rate from real data" do
    controller = DebtTransferController.new
    assert_equal 0.1028, controller.get_interest(debt_modality: :credit_card,
      date: "03/2011")
    assert_equal 0.1368, controller.get_interest(debt_modality: :check,
      date: "03/2011")
    assert_equal 0.0243, controller.get_interest(debt_modality: :payday_loan,
      date: "03/2011")
  end

  test "should get nil interest rate for dates out-of-scope" do
    controller = DebtTransferController.new
    assert_nil controller.get_interest(debt_modality: :credit_card,
      date: "01/2010")
    assert_nil controller.get_interest(debt_modality: :credit_card,
      date: "01/2017")
    assert_nil controller.get_interest(debt_modality: :credit_card,
      date: 2017)
  end

  test "should simulate credit card debt with real data" do
    controller = DebtTransferController.new
    assert_equal 105.67, controller.calculate_credit_card_debt(debt: 100,
      due_date: "03/2011", minimum_charge: 50)
    assert_equal 216.62, controller.calculate_credit_card_debt(debt: 200,
      due_date: "01/2013", minimum_charge: 75)
  end
end

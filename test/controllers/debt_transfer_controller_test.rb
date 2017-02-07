require 'test_helper'

class DebtTransferControllerTest < ActionDispatch::IntegrationTest
  test "should get root" do
    get root_url
    assert_response :success
  end

  test "should calculate debts" do
    get root_url, params: { invoice_value: 1000.00, invoice_due_date: "01/2015", minimum_charge: 100.00 }
    assert_select 'h1', "Dívida total"
  end
end

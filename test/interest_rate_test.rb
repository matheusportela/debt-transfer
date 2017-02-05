require_relative '../lib/interest_rate'

class InterestRateTest < ActiveSupport::TestCase
    test "should get default zero interest rates" do
        interest_rate = InterestRate.new
        assert_equal 0.0, interest_rate.get_rate
    end

    test "should get default interest rate with defined date" do
        interest_rate = InterestRate.new
        assert_equal 0.0, interest_rate.get_rate(date: "01/2016")
    end

    test "should load interest rate for specific date" do
        interest_rate = InterestRate.new
        interest_rate.load_rate 0.1, "01/2016"
        interest_rate.load_rate 0.2, "02/2016"
        assert_equal 0.0, interest_rate.get_rate(date: "12/2015")
        assert_equal 0.1, interest_rate.get_rate(date: "01/2016")
        assert_equal 0.2, interest_rate.get_rate(date: "02/2016")
        assert_equal 0.0, interest_rate.get_rate(date: "03/2016")
    end

    test "should load series of interest rate" do
        interest_rate = InterestRate.new
        rates = {
            "01/2016" => 0.1,
            "02/2016" => 0.2,
            "03/2016" => 0.3
        }
        interest_rate.load_rates rates

        assert_equal 0.0, interest_rate.get_rate(date: "12/2015")
        assert_equal 0.1, interest_rate.get_rate(date: "01/2016")
        assert_equal 0.2, interest_rate.get_rate(date: "02/2016")
        assert_equal 0.3, interest_rate.get_rate(date: "03/2016")
        assert_equal 0.0, interest_rate.get_rate(date: "04/2016")
    end

    test "should iterate in interest rates" do
        interest_rate = InterestRate.new
        rates = {
            "01/2016" => 0.1,
            "02/2016" => 0.2,
            "03/2016" => 0.3,
            "05/2016" => 0.5
        }
        interest_rate.load_rates rates
        interest_rate.set_begin "12/2015"

        assert_equal 0.0, interest_rate.get_rate

        interest_rate.next()
        assert_equal 0.1, interest_rate.get_rate

        interest_rate.next()
        assert_equal 0.2, interest_rate.get_rate

        interest_rate.next()
        assert_equal 0.3, interest_rate.get_rate

        interest_rate.next()
        assert_equal 0.0, interest_rate.get_rate

        interest_rate.next()
        assert_equal 0.5, interest_rate.get_rate

        interest_rate.next()
        assert_equal 0.0, interest_rate.get_rate
    end
end
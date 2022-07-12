defmodule MoneyTest do
  use ExUnit.Case, async: false

  describe "add_amount_to_balance/2" do
    test "return {:ok, balance}" do
      result = Helpers.number_to_decimal(90)

      assert {:ok, ^result} = Money.add_amount_to_balance(Decimal.new(45), 45)
      assert {:ok, ^result} = Money.add_amount_to_balance(Decimal.new(45), 45.00)
    end
  end

  describe "substract_amount_from_balance/2" do
    test "return {:ok, balance}" do
      result = Helpers.number_to_decimal(90)
      zero_decimal = Helpers.number_to_decimal(0)

      assert {:ok, ^result} = Money.substract_amount_from_balance(Decimal.new(135), 45)
      assert {:ok, ^result} = Money.substract_amount_from_balance(Decimal.new(135), 45.00)
      assert {:ok, ^zero_decimal} = Money.substract_amount_from_balance(Decimal.new(1), 1.00)
    end

    test "return {:error, :not_enough_money}" do
      assert {:error, :not_enough_money} ==
               Money.substract_amount_from_balance(Decimal.new(45), 45.01)
    end
  end
end

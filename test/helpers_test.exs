defmodule HelpersTest do
  use ExUnit.Case, async: false

  describe "number_to_decimal/1" do
    test "returns decimal when integer was given as an argument" do
      result = Decimal.new(90) |> Decimal.round(2)

      assert ^result = Helpers.number_to_decimal(90)
    end

    test "returns decimal when float was given as an argument" do
      result = Decimal.new(90) |> Decimal.round(2)

      assert ^result = Helpers.number_to_decimal(90.00)
      assert ^result = Helpers.number_to_decimal(90.00000)
    end
  end
end

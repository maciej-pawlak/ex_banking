defmodule RateLimiterTest do
  use ExUnit.Case, async: false

  describe "check_rate/1" do
    test "returns :ok" do
      :ok = ExBanking.create_user("RateLimiter")

      assert :ok == RateLimiter.check_rate("RateLimiter")
    end

    test "returns {:error, :too_many_requests_to_user}" do
      :ok = ExBanking.create_user("RateLimiter2")

      Enum.map(1..10000, fn _x ->
        spawn(fn -> ExBanking.get_balance("RateLimiter2", "PLN") end)
      end)

      assert {:error, :too_many_requests_to_user} == RateLimiter.check_rate("RateLimiter2")
    end
  end
end

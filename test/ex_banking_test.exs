defmodule ExBankingTest do
  use ExUnit.Case, async: true
  doctest ExBanking

  describe "create_user/1" do
    test "returns :ok" do
      assert :ok == ExBanking.create_user("String")
    end

    test "returns {:error, :wrong_arguments}" do
      assert {:error, :wrong_arguments} == ExBanking.create_user(12345)
    end

    test "returns {:error, :user_already_exist}" do
      ExBanking.create_user("create_user")
      assert {:error, :user_already_exist} == ExBanking.create_user("create_user")
    end
  end

  describe "get_balance/2" do
    test "returns {:ok, balance}" do
      ExBanking.create_user("balance")
      assert {:ok, 0.00} == ExBanking.get_balance("balance", "EUR")

      ExBanking.deposit("balance", 500.26, "EUR")
      assert {:ok, 500.26} == ExBanking.get_balance("balance", "EUR")
    end

    test "returns {:error, :wrong_argument}" do
      assert {:error, :wrong_arguments} == ExBanking.get_balance("user", 500)
      assert {:error, :wrong_arguments} == ExBanking.get_balance(:user, "EUR")
    end

    test "returns {:error, :user_does_not_exist}" do
      assert {:error, :user_does_not_exist} == ExBanking.get_balance("user", "EUR")
    end

    test "returns {:error, :too_many_requests_to_user}" do
      user = "too_many_requests_get_balance"
      ExBanking.create_user(user)

      reserve_tokens(user)
      assert {:error, :too_many_requests_to_user} = ExBanking.get_balance(user, "EUR")
    end
  end

  describe "deposit/3" do
    test "returns {:ok, new_balance} after deposit" do
      ExBanking.create_user("deposit")

      assert {:ok, 2000.88} == ExBanking.deposit("deposit", 2000.88, "EUR")
      assert {:ok, 2500.88} == ExBanking.deposit("deposit", 500.00, "EUR")
      assert {:ok, 2555.88} == ExBanking.deposit("deposit", 55, "EUR")
    end

    test "returns {:error, :wrong_arguments} when wrong arguments are given" do
      assert {:error, :wrong_arguments} == ExBanking.deposit("Mark", "2000.00", "EUR")
    end

    test "returns {:error, :user_does_not_exist}" do
      assert {:error, :user_does_not_exist} == ExBanking.deposit("Sue", 500.00, "USD")
    end

    test "returns {:error, :too_many_requests_to_user}" do
      user = "too_many_deposit_requests"
      ExBanking.create_user(user)

      reserve_tokens(user)
      Enum.map(1..1000, fn _x -> spawn(fn -> ExBanking.deposit(user, 500.01, "EUR") end) end)

      assert {:error, :too_many_requests_to_user} ==
               ExBanking.deposit(user, 500.01, "EUR")
    end
  end

  describe "withdraw/3" do
    test "returns {:ok, new_balance} after withdraw" do
      ExBanking.create_user("Elle")
      ExBanking.deposit("Elle", 500.00, "EUR")

      assert {:ok, 200.00} == ExBanking.withdraw("Elle", 300.00, "EUR")
    end

    test "returns {:error, :not_enough_money} when withdraw amount is bigger than current balance" do
      ExBanking.create_user("Mark")
      ExBanking.create_user("Janet")
      ExBanking.deposit("Mark", 500.00, "EUR")

      assert {:error, :not_enough_money} == ExBanking.withdraw("Mark", 1000.75, "EUR")
      assert {:error, :not_enough_money} == ExBanking.withdraw("Janet", 100.00, "EUR")
    end

    test "returns {:error, :user_does_not_exist}" do
      assert {:error, :user_does_not_exist} == ExBanking.deposit("Thomas", 500.00, "EUR")
    end

    test "returns {:error, :wrong_arguments}" do
      assert {:error, :wrong_arguments} == ExBanking.deposit("Mark", :money, "EUR")
    end

    test "returns {:error, :too_many_requests_to_user}" do
      user = "too_many_withdraw_requests"
      ExBanking.create_user(user)
      ExBanking.deposit(user, 1500.00, "EUR")

      reserve_tokens(user)
      assert {:error, :too_many_requests_to_user} == ExBanking.withdraw(user, 500.12, "EUR")
    end
  end

  describe "send/4" do
    test "returns {:ok, from_user_balance, to_user_balance}" do
      currency = "EUR"
      sender = "John"
      receiver = "Doris"

      ExBanking.create_user(sender)
      ExBanking.create_user(receiver)
      ExBanking.deposit(sender, 2500.99, currency)

      assert {:ok, 2000.98, 500.01} == ExBanking.send(sender, receiver, 500.01, currency)
    end

    test "returns {:error, :not_enough_money}" do
      currency = "EUR"
      sender = "Kat"
      receiver = "Steven"

      ExBanking.create_user(sender)
      ExBanking.create_user(receiver)
      ExBanking.deposit(sender, 2500.00, currency)

      assert {:error, :not_enough_money} == ExBanking.send(sender, receiver, 3500.53, currency)
    end

    test "returns {:error, :wrong_arguments}" do
      assert {:error, :wrong_argument} == ExBanking.send(:sender, "receiver", 500.00, "EUR")
      assert {:error, :wrong_argument} == ExBanking.send("sender", :receiver, 500.00, "EUR")
      assert {:error, :wrong_argument} == ExBanking.send("sender", "receiver", :money, "EUR")
      assert {:error, :wrong_argument} == ExBanking.send("sender", "receiver", 500.00, :EUR)
    end

    test "returns {:error, :sender_does_not_exist}" do
      currency = "EUR"
      receiver = "Anna"
      sender = "Peter"

      ExBanking.create_user(receiver)

      assert {:error, :sender_does_not_exist} ==
               ExBanking.send(sender, receiver, 3500.34, currency)
    end

    test "returns {:error, :receiver_does_not_exist}" do
      currency = "EUR"
      sender = "Ethan"
      receiver = "Greg"

      ExBanking.create_user(sender)
      ExBanking.create_user(receiver)
      ExBanking.deposit(sender, 2500.00, currency)

      assert {:error, :not_enough_money} == ExBanking.send(sender, receiver, 3500.00, currency)
    end

    test "returns {:error, :too_many_requests_to_sender}" do
      currency = "EUR"
      sender = "Tom"
      receiver = "Janet"

      ExBanking.create_user(sender)
      ExBanking.create_user(receiver)

      reserve_tokens(sender)

      assert {:error, :too_many_requests_to_sender} ==
               ExBanking.send(sender, receiver, 3500.00, currency)
    end

    test "returns {:error, :too_many_requests_to_receiver}" do
      currency = "EUR"
      sender = "Mallory"
      receiver = "Mike"

      ExBanking.create_user(sender)
      ExBanking.create_user(receiver)

      reserve_tokens(receiver)

      assert {:error, :too_many_requests_to_receiver} ==
               ExBanking.send(sender, receiver, 3500.00, currency)
    end
  end

  defp reserve_tokens(user) do
    Enum.map(1..10, fn _x -> RateLimiter.check_rate(user) end)
  end
end

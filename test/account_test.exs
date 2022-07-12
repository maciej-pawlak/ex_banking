defmodule AccountTest do
  use ExUnit.Case, async: false

  describe "create_user/1" do
    test "returns :ok" do
      assert :ok == Account.create_user("user")
    end

    test "returns {:error, :user_already_exist}" do
      :ok = Account.create_user("Maciej")
      assert {:error, :user_already_exist} == Account.create_user("Maciej")
    end
  end

  describe "get_balance/2" do
    test "returns {:ok, balance}" do
      :ok = Account.create_user("Mac")

      assert {:ok, 0.00} == Account.get_balance("Mac", "EUR")

      Account.add_money_to_account("Mac", 500.55, "EUR")

      assert {:ok, 500.55} == Account.get_balance("Mac", "EUR")
    end

    test "returns {:error, :user_does_not_exist}" do
      assert {:error, :user_does_not_exist} == Account.get_balance("IamNotExist", "USD")
    end
  end

  describe "transfer_money/4" do
    test "returns {:ok, sender_balance, receiver_balance}" do
      :ok = Account.create_user("Sender")
      :ok = Account.create_user("Receiver")

      Account.add_money_to_account("Sender", 500.01, "EUR")

      assert {:ok, 00.02, 499.99} == Account.transfer_money("Sender", "Receiver", 499.99, "EUR")
    end

    test "returns {:error, :not_enough_money}" do
      :ok = Account.create_user("Sender2")
      :ok = Account.create_user("Receiver2")

      Account.add_money_to_account("Sender2", 500.01, "EUR")

      assert {:error, :not_enough_money} ==
               Account.transfer_money("Sender2", "Receiver2", 500.02, "EUR")
    end

    test "returns {:error, :sender_does_not_exist}" do
      :ok = Account.create_user("Receiver3")

      assert {:error, :sender_does_not_exist} ==
               Account.transfer_money("Sender3", "Receiver3", 500.02, "EUR")
    end

    test "returns {:error, :receiver_does_not_exist}" do
      :ok = Account.create_user("Sender4")

      assert {:error, :receiver_does_not_exist} ==
               Account.transfer_money("Sender4", "Receiver4", 500.02, "EUR")
    end
  end

  describe "add_money_to_account/3" do
    test "returns {:ok, balance}" do
      :ok = Account.create_user("User1")

      assert {:ok, 123.45} == Account.add_money_to_account("User1", 123.45, "PLN")
    end

    test "returns {:error, :user_does_not_exist}" do
      assert {:error, :user_does_not_exist} ==
               Account.add_money_to_account("User2", 123.45, "PLN")
    end
  end

  describe "substract_money_from_account/3" do
    test "returns {:ok, balance}" do
      :ok = Account.create_user("User3")
      Account.add_money_to_account("User3", 123.45, "PLN")

      assert {:ok, 00.00} == Account.substract_money_from_account("User3", 123.45, "PLN")
    end

    test "returns {:error, :not_enough_money}" do
      :ok = Account.create_user("User4")
      Account.add_money_to_account("User4", 123.45, "PLN")

      assert {:error, :not_enough_money} ==
               Account.substract_money_from_account("User4", 123.46, "PLN")
    end

    test "returns {:error, :user_does_not_exist}" do
      assert {:error, :user_does_not_exist} ==
               Account.substract_money_from_account("User5", 123.46, "PLN")
    end
  end
end

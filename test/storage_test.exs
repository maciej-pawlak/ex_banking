defmodule StorageTest do
  use ExUnit.Case, async: false

  describe "insert_user/1" do
    test "returns :ok" do
      assert :ok == Storage.insert_user("StorageUser")
    end

    test "returns {:error, :user_already_exist}" do
      :ok = Storage.insert_user("StorageUser1")

      assert {:error, :user_already_exist} == Storage.insert_user("StorageUser1")
    end
  end

  describe "insert_updated_account/" do
    test "returns :ok" do
      :ok = Storage.insert_user("StorageUser2")

      assert :ok == Storage.insert_updated_account("StorageUser2", %{account: 1})
    end
  end

  describe "fetch_user_accounts" do
    test "returns {:ok, accounts}" do
      :ok = Storage.insert_user("StorageUser3")

      assert {:ok, %{}} == Storage.fetch_user_accounts("StorageUser3")
    end

    test "returns {:error, :user_does_not_exist}" do
      assert {:error, :user_does_not_exist} == Storage.fetch_user_accounts("StorageUser4")
    end
  end
end

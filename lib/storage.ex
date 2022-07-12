defmodule Storage do
  @moduledoc """
  Storage module is responsible for all data manipulations.
  """

  @doc """
  Function add user to storage. In case user already exist `{:error, :user_already_exist}` is returned.
  """
  @spec insert_user(user :: String.t()) :: :ok | {:error, :user_already_exist}
  def insert_user(user) do
    case :ets.insert_new(:users, {user, %{}}) do
      true -> :ok
      false -> {:error, :user_already_exist}
    end
  end

  @doc """
  Function insert updated user account to storage.
  """
  @spec insert_updated_account(user :: String.t(), updated_accounts :: map()) :: :ok
  def insert_updated_account(user, updated_accounts) do
    :ets.insert(:users, {user, updated_accounts})

    :ok
  end

  @doc """
  Function fetch user accounts.
  """
  @spec fetch_user_accounts(user :: String.t()) ::
          {:ok, accounts :: map()} | {:error, :user_does_not_exist}
  def fetch_user_accounts(user) do
    case :ets.match_object(:users, {user, :_}) do
      [{_user, accounts}] -> {:ok, accounts}
      [] -> {:error, :user_does_not_exist}
    end
  end
end

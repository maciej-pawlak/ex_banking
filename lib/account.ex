defmodule Account do
  @moduledoc """
  Account module is responsible for all manipulations on users accounts.
  """

  @doc """
  Function creates new user in the system.
  """
  @spec create_user(user :: String.t()) :: :ok | {:error, :user_already_exists}
  def create_user(user), do: Storage.insert_user(user)

  @doc """
  Function returns user account balance.
  """
  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:ok, balance :: float()} | {:error, :user_does_not_exist}
  def get_balance(user, currency) do
    with {:ok, %{^currency => amount}} <- Storage.fetch_user_accounts(user) do
      {:ok, Decimal.to_float(amount)}
    else
      {:ok, _accounts} -> {:ok, 0.0}
      error -> error
    end
  end

  @doc """
  Function transfer money from user A to user B if user A balance is sufficient.
  """
  @spec transfer_money(
          from_user :: String.t(),
          to_user :: String.t(),
          amount :: number(),
          currency :: String.t()
        ) ::
          {:ok, sender_balance :: float(), receiver_balance :: float()}
          | {:error, :sender_does_not_exist}
          | {:error, :receiver_does_not_exist}
          | {:error, :not_enough_money}
  def transfer_money(from_user, to_user, amount, currency) do
    with {:ok, _balance} <- get_sender_balance(from_user, currency),
         {:ok, _balance} <- get_receiver_balance(to_user, currency),
         {:ok, sender_balance} <- substract_money_from_account(from_user, amount, currency),
         {:ok, receiver_balance} <- add_money_to_account(to_user, amount, currency) do
      {:ok, sender_balance, receiver_balance}
    else
      error -> error
    end
  end

  @doc """
  Functions adds money to gicen user account.
  """
  @spec add_money_to_account(user :: String.t(), amount :: number(), currency :: String.t()) ::
          {:ok, balance :: float()} | {:error, :user_does_not_exist}
  def add_money_to_account(user, amount, currency) do
    with {:ok, %{^currency => balance} = accounts} <- Storage.fetch_user_accounts(user),
         {:ok, new_balance} <- Money.add_amount_to_balance(balance, amount),
         {:ok, :account_updated} <- update_account(user, accounts, currency, new_balance) do
      {:ok, Decimal.to_float(new_balance)}
    else
      {:ok, accounts} ->
        new_balance = Helpers.number_to_decimal(amount)
        {:ok, :account_updated} = update_account(user, accounts, currency, new_balance)

        {:ok, Decimal.to_float(new_balance)}

      error ->
        error
    end
  end

  @doc """
  Function substracts money from given user account if balance is sufficient.
  """
  @spec substract_money_from_account(
          user :: String.t(),
          amount :: number(),
          currency :: String.t()
        ) ::
          {:ok, balance :: float()} | {:error, :not_enough_money | :user_does_not_exist}
  def substract_money_from_account(user, amount, currency) do
    with {:ok, %{^currency => balance} = accounts} <- Storage.fetch_user_accounts(user),
         {:ok, new_balance} <- Money.substract_amount_from_balance(balance, amount),
         {:ok, :account_updated} <- update_account(user, accounts, currency, new_balance) do
      {:ok, Decimal.to_float(new_balance)}
    else
      {:ok, _accounts} -> {:error, :not_enough_money}
      error -> error
    end
  end

  defp update_account(user, accounts, currency, new_balance) do
    updated_accounts = Map.put(accounts, currency, new_balance)
    :ok = Storage.insert_updated_account(user, updated_accounts)

    {:ok, :account_updated}
  end

  defp get_sender_balance(user, currency) do
    case Account.get_balance(user, currency) do
      {:ok, balance} -> {:ok, balance}
      {:error, :user_does_not_exist} -> {:error, :sender_does_not_exist}
    end
  end

  defp get_receiver_balance(user, currency) do
    case Account.get_balance(user, currency) do
      {:ok, balance} -> {:ok, balance}
      {:error, :user_does_not_exist} -> {:error, :receiver_does_not_exist}
    end
  end
end

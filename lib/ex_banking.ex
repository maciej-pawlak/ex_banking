defmodule ExBanking do
  @moduledoc """
  Documentation for `ExBanking`.
  """

  @doc """
  Function creates new user in the system.
  New user has zero balance of any currency.
  """
  @spec create_user(user :: String.t()) :: :ok | {:error, :wrong_arguments | :user_already_exists}
  def create_user(user) when is_bitstring(user), do: Account.create_user(user)
  def create_user(_), do: {:error, :wrong_arguments}

  @doc """
  Increases user’s balance in given currency by amount value.
  Returns new_balance of the user in given format.
  """
  @spec deposit(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error,
             :wrong_arguments
             | :user_does_not_exist
             | :too_many_requests_to_user}
  def deposit(user, amount, currency)
      when is_bitstring(user) and
             is_bitstring(currency) and
             is_number(amount) and
             amount > 0 do
    case RateLimiter.check_rate(user) do
      :ok ->
        result = Account.add_money_to_account(user, amount, currency)
        RateLimiter.release_token(user)

        result

      error ->
        error
    end
  end

  def deposit(_, _, _), do: {:error, :wrong_arguments}

  @doc """
  Decreases user’s balance in given currency by amount value.
  Returns new_balance of the user in given format.
  """
  @spec withdraw(user :: String.t(), amount :: number, currency :: String.t()) ::
          {:ok, new_balance :: number}
          | {:error,
             :wrong_arguments
             | :user_does_not_exist
             | :not_enough_money
             | :too_many_requests_to_user}
  def withdraw(user, amount, currency)
      when is_bitstring(user) and
             is_bitstring(currency) and
             is_number(amount) do
    case RateLimiter.check_rate(user) do
      :ok ->
        result = Account.substract_money_from_account(user, amount, currency)
        RateLimiter.release_token(user)

        result

      error ->
        error
    end
  end

  def withdraw(_, _, _), do: {:error, :wrong_arguments}

  @doc """
  Returns balance of the user in given format.
  """
  @spec get_balance(user :: String.t(), currency :: String.t()) ::
          {:ok, balance :: number}
          | {:error,
             :wrong_arguments
             | :user_does_not_exist
             | :too_many_requests_to_user}
  def get_balance(user, currency) when is_bitstring(user) and is_bitstring(currency) do
    case RateLimiter.check_rate(user) do
      :ok ->
        result = Account.get_balance(user, currency)
        RateLimiter.release_token(user)

        result

      error ->
        error
    end
  end

  def get_balance(_, _), do: {:error, :wrong_arguments}

  @doc """
  Decreases from_user’s balance in given currency by amount value.
  Increases to_user’s balance in given currency by amount value.
  Returns balance of from_user and to_user in given format.
  """
  @spec send(
          from_user :: String.t(),
          to_user :: String.t(),
          amount :: number,
          currency :: String.t()
        ) ::
          {:ok, from_user_balance :: number, to_user_balance :: number}
          | {:error,
             :wrong_arguments
             | :not_enough_money
             | :sender_does_not_exist
             | :receiver_does_not_exist
             | :too_many_requests_to_sender
             | :too_many_requests_to_receiver}
  def send(from_user, to_user, amount, currency)
      when is_bitstring(from_user) and
             is_bitstring(to_user) and
             is_bitstring(currency) and
             is_number(amount) do
    with :ok <- RateLimiter.check_sender_rate(from_user),
         :ok <- RateLimiter.check_receiver_rate(to_user) do
      result = Account.transfer_money(from_user, to_user, amount, currency)

      RateLimiter.release_token(from_user)
      RateLimiter.release_token(to_user)

      result
    else
      error -> error
    end
  end

  def send(_, _, _, _), do: {:error, :wrong_argument}
end

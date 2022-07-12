defmodule Money do
  @moduledoc """
  Money module is responsible for all calculations on money.
  """

  @doc """
  Function add amount to balance.
  """
  @spec add_amount_to_balance(balance :: Decimal.t(), amount :: number) :: {:ok, Decimal.t()}
  def add_amount_to_balance(balance, amount) do
    new_balance = Decimal.add(balance, Helpers.number_to_decimal(amount))

    {:ok, new_balance}
  end

  @doc """
  Function substract amount from balance.
  Returns `{:error, :not_enough_money}` if result is negative.
  """
  @spec substract_amount_from_balance(balance :: Decimal.t(), amount :: number) ::
          {:ok, Decimal.t()} | {:error, :not_enough_money}
  def substract_amount_from_balance(balance, amount) do
    new_balance = Decimal.sub(balance, Helpers.number_to_decimal(amount))

    case Decimal.lt?(new_balance, "0.00") do
      false -> {:ok, new_balance}
      true -> {:error, :not_enough_money}
    end
  end
end

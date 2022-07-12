defmodule Helpers do
  @moduledoc """
  Module with helper functions
  """

  @doc """
  Function parse number (float or integer) to decimal
  """
  @spec number_to_decimal(number) :: Decimal.t()
  def number_to_decimal(number) when is_integer(number) do
    number
    |> Decimal.new()
    |> Decimal.round(2)
  end

  def number_to_decimal(number) when is_float(number) do
    number
    |> Decimal.from_float()
    |> Decimal.round(2, :down)
  end

  def run_many(user) do
    ExBanking.get_balance(user, "EUR")
    IO.puts("se chodze")
    run_many(user)
  end

  def run_maany(user) do
    spawn(fn -> run_many(user) end)
  end
end

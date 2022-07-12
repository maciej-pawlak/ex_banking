defmodule LeakyBucket do
  @moduledoc """
  Naive implementation of leaky bucket rate limiter.
  """
  @limit 10

  def check_rate(user) do
    current_rate =
      case get(user) do
        [] -> 0
        [{^user, rate}] -> rate
      end

    case current_rate >= @limit do
      true ->
        {:deny, @limit}

      false ->
        reserve_token(user)

        {:allow, current_rate}
    end
  end

  def release_token(user) do
    case get(user) do
      [] ->
        nil

      [{^user, 1}] ->
        delete(user)

      [{^user, rate}] ->
        {user, rate - 1}
        |> insert()
    end

    :ok
  end

  defp reserve_token(user) do
    case get(user) do
      [] -> {user, 1}
      [{^user, rate}] -> {user, rate + 1}
    end
    |> insert()

    :ok
  end

  defp get(user) do
    :ets.match_object(:rate_limiter, {user, :_})
  end

  defp insert(object) do
    :ets.insert(:rate_limiter, object)
  end

  defp delete(user) do
    :ets.delete(:rate_limiter, user)
  end
end

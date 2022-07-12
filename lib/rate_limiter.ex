defmodule RateLimiter do
  @moduledoc """
  RateLimiter module is responsible for limiting user requests.
  """

  @spec check_rate(user :: String.t()) :: :ok | {:error, :too_many_requests_to_user}
  def check_rate(user) do
    case LeakyBucket.check_rate(user) do
      {:allow, _count} -> :ok
      {:deny, _limit} -> {:error, :too_many_requests_to_user}
    end
  end

  def release_token(user), do: LeakyBucket.release_token(user)

  @spec check_sender_rate(user :: String.t()) :: :ok | {:error, :too_many_requests_to_sender}
  def check_sender_rate(user) do
    case check_rate(user) do
      :ok -> :ok
      {:error, _} -> {:error, :too_many_requests_to_sender}
    end
  end

  @spec check_receiver_rate(user :: String.t()) :: :ok | {:error, :too_many_requests_to_receiver}
  def check_receiver_rate(user) do
    case check_rate(user) do
      :ok -> :ok
      {:error, _} -> {:error, :too_many_requests_to_receiver}
    end
  end
end

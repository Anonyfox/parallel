defmodule Parallel do
  @moduledoc """
    This module contains some often-needed variants of Elixir's `Enum`
    functions, naively implemented as concurrent variants. Every `List` item
    will be processed in a separate erlang process, so use this only if the
    individual task takes longer than a simple calculation to speed things up.

    To support heavy IO-bound workloads, no worker pool is used here, but
    *every* list item is processed in parallel! So if you have a billion CPU-
    bound tasks, use any other parallel map implementation.
  """

  @doc """
    The most common usecase on lists: apply a function to each list item. Since
    these operations are concurrent (a process is spawned per list item), the
    ordering of list elements is **not** guaranteed!
  """

  @spec map([any], (any -> any)) :: [any]

  def map(list, fun) do
    list
    |> Stream.map(fn(item) -> dispatch(fun).(item) end)
    |> Enum.map(fn(pid) -> collect.(pid) end)
  end

  @doc """
    Same as `Parallel.map`, but returns an atom (:ok)
  """

  @spec each([any], (any -> any)) :: atom

  def each(list, fun) do
    Parallel.map(list, fun)
    :ok
  end

  @doc """
    Returns only elements for which the truth test passes.
  """

  @spec filter([any], (any -> any)) :: [any]

  def filter(list, fun) do
    list
    |> Stream.map(fn(item) -> {dispatch(fun).(item), item} end)
    |> Stream.map(fn({pid, item}) -> {collect.(pid), item} end)
    |> Stream.filter(fn({bool, _item}) -> bool == true end)
    |> Enum.map(fn({_bool, item}) -> item end)
  end

  @doc """
    Returns only elements for which the truth test does not pass, opposite of
    `Parallel.filter`.
  """

  @spec reject([any], (any -> any)) :: [any]

  def reject(list, fun) do
    list
    |> Stream.map(fn(item) -> {dispatch(fun).(item), item} end)
    |> Stream.map(fn({pid, item}) -> {collect.(pid), item} end)
    |> Stream.filter(fn({bool, _item}) -> bool == false end)
    |> Enum.map(fn({_bool, item}) -> item end)
  end

  def all?(list, fun), do: length(filter(list,fun)) == length(list)
  def any?(list, fun), do: length(filter(list,fun)) > 0

  # -------------------------------------------------------------

  # helper function to spawn a new process for a single list item
  defp dispatch(fun) do
    caller = self
    fn(item) ->
      spawn fn ->
        send(caller, fun.(item))
      end
    end
  end

  # helper function to receive the calculation result for a single list item
  defp collect do
    fn(_) ->
      receive do
        result -> result
      end
    end
  end

end

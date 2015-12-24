defmodule Onetime do
  @moduledoc """
  This is a onetime key-value store.
  This can be used for such as storing tokens for authentication.
  """
  use GenServer
  alias Timex.Date, as: Date

  @type result :: {:ok, any} | :error

  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, %{}, options)
  end

  @doc """
  Registers the key with specific time.
  """
  @spec register(any, any, any, number) :: any
  def register(name, key, value, time) do
    GenServer.cast(name, {:register, {key, value, time}})
  end

  @doc """
  Registers the key.
  """
  @spec register(any, any, any) :: any
  def register(name, key, value) do
    register(name, key, value, Date.now())
  end

  @doc """
  Drops the key.
  """
  @spec drop(any, any) :: any
  def drop(name, key) do
    GenServer.cast(name, {:drop, key})
  end

  @doc """
  Checks whether the key exists or not.
  """
  @spec has?(any, any, number) :: boolean
  def has?(name, key, secs \\ :infinity) do
    case get(name, key, secs) do
      {:ok, _} -> true
      _ -> false
    end
  end

  @doc """
  Returns the value for a given key.
  """
  @spec get(any, any, number) :: result
  def get(name, key, secs \\ :infinity) do
    GenServer.call(name, {:get, {key, secs}})
  end

  @doc """
  Returns the value for a given key and removes them.
  """
  @spec get(any, any, number) :: result
  def pop(name, key, secs \\ :infinity) do
    GenServer.call(name, {:pop, {key, secs}})
  end

  @doc """
  Returns the value for a given key and changes the key.
  """
  @spec get_and_update(any, any, any, number) :: result
  def get_and_update(name, key, new_key, secs \\ :infinity) do
    GenServer.call(name, {:pop, {key, new_key, secs}})
  end

  @doc """
  Returns the all keys and values.
  """
  @spec get_all(any, number) :: map
  def get_all(name, secs \\ :infinity) do
    GenServer.call(name, {:get_all, secs})
  end

  @doc """
  Remove the old keys and values.
  """
  @spec clear(any, number) :: map
  def clear(name, secs) do
    GenServer.cast(name, {:clear, secs})
  end

  defp get_from_map(map, key, now, secs) do
    case Map.get(map, key) do
      {value, time} ->
        if secs != :infinity && Date.diff(time, now, :secs) > secs do
          :error
        else
          {:ok, value}
        end
        _ -> :error
    end
  end

  # Callbacks

  def handle_cast({:register, {key, value, time}}, map) do
    {:noreply, Map.put(map, key, {value, time})}
  end

  def handle_cast({:drop, key}, map) do
    {:noreply, Map.delete(map, key)}
  end

  def handle_cast({:clear, secs}, map) do
    map = if secs != :infinity do
      now = Date.now()
      Enum.filter(map, fn {_key, {_value, time}} -> Date.diff(time, now, :secs) < secs end)
    else map end
    {:noreply, map}
  end

  def handle_call({:get, {key, secs}}, _from, map) do
    reply = get_from_map(map, key, Date.now(), secs)
    {:reply, reply, map}
  end

  def handle_call({:pop, {key, secs}}, _from, map) do
    reply = get_from_map(map, key, Date.now(), secs)
    {:reply, reply, Map.delete(map, key)}
  end

  def handle_call({:pop, {key, new_key, secs}}, _from, map) do
    now = Date.now()
    reply = get_from_map(map, key, now, secs)
    map = if reply != :error do
      Map.delete(map, key)
      |> Map.put(new_key, {elem(reply, 1), now})
    else
      Map.delete(map, key)
    end
    {:reply, reply, map}
  end

  def handle_call({:get_all, secs}, _from, map) do
    map = if secs != :infinity do
      now = Date.now()
      Enum.filter(map, fn {_key, {_value, time}} -> Date.diff(time, now, :secs) < secs end) |> Enum.into(%{})
    else map end
    reply = Enum.map(map, fn {key, {value, _time}} -> {key, value} end) |> Enum.into(%{})
    {:reply, reply, map}
  end
end

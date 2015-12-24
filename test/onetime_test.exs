defmodule OnetimeTest do
  use ExUnit.Case
  alias Timex.Date, as: Date
  doctest Onetime

  setup do
    {:ok, pid} = Onetime.start_link()
    {:ok, pid: pid}
  end

  test "register and pop", context do
    Onetime.register(context[:pid], :a, :A)
    assert :error == Onetime.pop(context[:pid], :b)
    assert {:ok, :A} == Onetime.pop(context[:pid], :a)
  end

  test "pop with secs", context do
    Onetime.register(context[:pid], :a, :A)
    Onetime.register(context[:pid], :b, :B, Date.now() |> Date.shift(secs: -1001))
    Onetime.register(context[:pid], :c, :C, Date.now() |> Date.shift(secs: -1000))
    assert {:ok, :A} == Onetime.pop(context[:pid], :a, 1000)
    assert :error == Onetime.pop(context[:pid], :b, 1000)
    assert {:ok, :C} == Onetime.pop(context[:pid], :c, 1000)
  end

  test "key is onetime", context do
    Onetime.register(context[:pid], :a, :A)
    assert {:ok, :A} == Onetime.pop(context[:pid], :a)
    assert :error == Onetime.pop(context[:pid], :a)
  end

  test "get_and_update", context do
    Onetime.register(context[:pid], :a, :A)
    assert {:ok, :A} == Onetime.get_and_update(context[:pid], :a, :b)
    assert :error == Onetime.pop(context[:pid], :a)
    assert {:ok, :A} == Onetime.pop(context[:pid], :b)
  end

  test "get", context do
    Onetime.register(context[:pid], :a, :A)
    assert {:ok, :A} == Onetime.get(context[:pid], :a)
    assert {:ok, :A} == Onetime.pop(context[:pid], :a)
  end

  test "has?", context do
    Onetime.register(context[:pid], :a, :A)
    assert true == Onetime.has?(context[:pid], :a)
    assert false == Onetime.has?(context[:pid], :b)
  end

  test "get_all", context do
    assert Enum.empty? Onetime.get_all(context[:pid])
    Onetime.register(context[:pid], :a, :A)
    Onetime.register(context[:pid], :b, :B)
    Onetime.register(context[:pid], :c, :C)
    Onetime.pop(context[:pid], :b)
    assert %{a: :A, c: :C} == Onetime.get_all(context[:pid], 1000)
  end

  test "get_all with secs", context do
    Onetime.register(context[:pid], :a, :A)
    Onetime.register(context[:pid], :b, :B, Date.now() |> Date.shift(secs: -1000))
    Onetime.register(context[:pid], :c, :C, Date.now() |> Date.shift(secs: -999))
    assert %{a: :A, c: :C} == Onetime.get_all(context[:pid], 1000)
  end

  test "clear", context do
    Onetime.register(context[:pid], :a, :A)
    Onetime.register(context[:pid], :b, :B, Date.now() |> Date.shift(secs: -1000))
    Onetime.register(context[:pid], :c, :C, Date.now() |> Date.shift(secs: -999))
    Onetime.clear(context[:pid], 1000)
    assert %{a: :A, c: :C} == Onetime.get_all(context[:pid])
  end

  test "drop", context do
    Onetime.register(context[:pid], :a, :A)
    Onetime.drop(context[:pid], :a)
    assert :error == Onetime.pop(context[:pid], :a)
  end
end

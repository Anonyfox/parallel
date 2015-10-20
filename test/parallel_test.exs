defmodule ParallelTest do
  use ExUnit.Case

  test "map" do
    assert Parallel.map(1..3, &increment/1) == [2,3,4]
    assert Parallel.map(1..1_000, &increment/1) == Enum.to_list(2..1_001)
    assert Parallel.map([1,2,3], &Kernel.to_string/1) == ["1","2","3"]
  end

  test "filter" do
    assert Parallel.filter([1,2,3], &is_even/1) == [2]
    assert Parallel.filter([2,3,4], &is_even/1) == [2,4]
  end

  test "reject" do
    assert Parallel.reject([1,2,3], &is_even/1) == [1,3]
    assert Parallel.reject([2,3,4], &is_even/1) == [3]
  end

  test "all?" do
    assert Parallel.all?([1,true,"a"], &is_truthy/1) == true
    assert Parallel.all?([1,false,"b"], &is_truthy/1) == false
  end

  test "any?" do
    assert Parallel.any?([nil,true,false], &is_truthy/1) == true
    assert Parallel.any?([nil,false,false], &is_truthy/1) == false
  end

  defp increment(x), do: x + 1
  defp is_even(x), do: rem(x,2) == 0
  defp is_truthy(x), do: !!x
end

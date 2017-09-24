defmodule WarehouseTest do
  use ExUnit.Case
  doctest Warehouse

  test "greets the world" do
    assert Warehouse.hello() == :world
  end
end

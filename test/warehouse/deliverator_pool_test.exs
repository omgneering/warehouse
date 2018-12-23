defmodule DeliveratorPoolTest do
  use ExUnit.Case
  alias Warehouse.{DeliveratorPool}

  setup do
    # set DeliveratorPool to initial state
    state = :sys.get_state(DeliveratorPool)
    state.deliverators
    |> Enum.each(fn({pid, _status}) -> DeliveratorPool.remove_deliverator(pid) end)
  end

  describe "#available_deliverator" do
    test "fetches and adds idle deliverator" do
      {:ok, pid} = DeliveratorPool.available_deliverator
      state = :sys.get_state(DeliveratorPool)
      assert is_pid(pid)
      assert Enum.count(state.deliverators) > 0
    end

    test "fetches idle deliverator" do
      {:ok, _} = DeliveratorPool.available_deliverator
      {:ok, pid} = DeliveratorPool.available_deliverator
      state = :sys.get_state(DeliveratorPool)
      assert is_pid(pid)
      assert Enum.count(state.deliverators) > 0
    end

    test "returns error when maxed out" do
      state = :sys.get_state(DeliveratorPool)
      number_to_add = state.max - Enum.count(state.deliverators)
      Stream.repeatedly(fn() ->
        {:ok, pid} = DeliveratorPool.available_deliverator
        DeliveratorPool.flag_deliverator_busy(pid)
      end)
      |> Enum.take(number_to_add)

      response = DeliveratorPool.available_deliverator

      assert {:error, _} = response
    end
  end

  describe "#remove_deliverator" do
    test "removes deliverator" do
      {:ok, pid} = DeliveratorPool.available_deliverator
      DeliveratorPool.remove_deliverator(pid)
      state = :sys.get_state(DeliveratorPool)
      refute(Enum.member?(state.deliverators, {pid, :idle}))
    end
  end

  describe "#flag_deliverator_busy" do
    test "flags deliverator busy" do
      {:ok, pid} = DeliveratorPool.available_deliverator
      DeliveratorPool.flag_deliverator_busy(pid)
      state = :sys.get_state(DeliveratorPool)
      assert(Enum.member?(state.deliverators, {pid, :busy}))
    end
  end

  describe "#flag_deliverator_idle" do
    test "flags deliverator idle" do
      {:ok, pid} = DeliveratorPool.available_deliverator
      DeliveratorPool.flag_deliverator_busy(pid)
      DeliveratorPool.flag_deliverator_idle(pid)
      state = :sys.get_state(DeliveratorPool)
      assert(Enum.member?(state.deliverators, {pid, :idle}))
    end
  end

end

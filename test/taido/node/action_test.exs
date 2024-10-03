defmodule Taido.Node.ActionTest do
  use ExUnit.Case, async: true

  alias Taido.BehaviorTree
  alias Taido.Node.Action

  test "executes the wrapped function" do
    test_pid = self()
    test_ref = make_ref()

    action = %Action{
      fun: fn _ ->
        send(test_pid, test_ref)
        :success
      end
    }

    BehaviorTree.tick(action, nil)

    assert_receive ^test_ref
  end

  test "passes state to the wrapped function" do
    test_pid = self()
    test_ref = make_ref()

    action = %Action{
      fun: fn ref ->
        send(test_pid, ref)
        :success
      end
    }

    BehaviorTree.tick(action, test_ref)

    assert_receive ^test_ref
  end

  test "returns the result of the wrapped function" do
    action = %Action{
      fun: fn _ ->
        :success
      end
    }

    assert {:success, _, _} = BehaviorTree.tick(action, nil)
  end

  test "returns the agent modified by the action" do
    action = %Action{
      fun: fn agent ->
        {:success, agent + 1}
      end
    }

    assert {:success, _, 2} = BehaviorTree.tick(action, 1)
  end

  test "returns the action" do
    action = %Action{
      fun: fn nil ->
        :success
      end
    }

    assert {:success, ^action, _} = BehaviorTree.tick(action, nil)
  end
end

defmodule Taido.Node.AsyncActionTest do
  use ExUnit.Case, async: true

  alias Taido.BehaviorTree
  alias Taido.Node.AsyncAction

  test "executes the wrapped function" do
    test_pid = self()
    test_ref = make_ref()

    tree = %AsyncAction{
      fun: fn _ ->
        send(test_pid, test_ref)
        :success
      end
    }

    assert {:running, tree, _state} = BehaviorTree.tick(tree, nil)

    assert_receive ^test_ref

    assert {:success, _tree, _state} = BehaviorTree.tick(tree, nil)
  end

  test "passes state to the wrapped function" do
    test_pid = self()
    test_ref = make_ref()

    action = %AsyncAction{
      fun: fn ref ->
        send(test_pid, ref)
        :success
      end
    }

    assert {:running, action, _} = BehaviorTree.tick(action, test_ref)

    assert_receive ^test_ref

    assert {:success, _action, _} = BehaviorTree.tick(action, nil)
  end

  test "returns the agent modified by the action" do
    action = %AsyncAction{
      fun: fn agent ->
        {:success, agent + 1}
      end
    }

    assert {:running, action, 1} = BehaviorTree.tick(action, 1)
    assert {:success, _action, 2} = BehaviorTree.tick(action, 1)
  end
end

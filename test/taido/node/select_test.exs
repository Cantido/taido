defmodule Taido.Node.SelectTest do
  use ExUnit.Case, async: true

  alias Taido.BehaviorTree
  alias Taido.Node.Select
  alias Taido.Node.Action

  test "stops on first action that succeeds" do
    select = %Select{
      nodes: [
        %Action{fun: fn _ -> :success end},
        %Action{fun: fn _ -> flunk("The second action in this select should not be executed") end}
      ]
    }

    assert {:success, _, _} = BehaviorTree.tick(select, nil)
  end

  test "restarts after a success" do
    select = %Select{
      nodes: [
        %Action{fun: fn _ -> :success end},
        %Action{fun: fn _ -> flunk("The second action in this select should not be executed") end}
      ]
    }

    assert {:success, _, _} = BehaviorTree.tick(select, nil)
    assert {:success, _, _} = BehaviorTree.tick(select, nil)
  end

  test "executes the second action if the first one fails" do
    select = %Select{
      nodes: [
        %Action{fun: fn _ -> :failure end},
        %Action{fun: fn _ -> :success end},
        %Action{fun: fn _ -> flunk("The third action in this select should not be executed") end}
      ]
    }

    assert {:success, _, _} = BehaviorTree.tick(select, nil)
  end

  test "each action can update the agent" do
    select = %Select{
      nodes: [
        %Action{fun: fn {nil, nil} -> {:failure, {:first, nil}} end},
        %Action{fun: fn {:first, nil} -> {:success, {:first, :second}} end}
      ]
    }

    assert {:success, _, {:first, :second}} = BehaviorTree.tick(select, {nil, nil})
  end

  test "halts and maintains a counter when an action returns :running" do
    select = %Select{
      nodes: [
        %Action{fun: fn _ -> {:failure, [:first]} end},
        %Action{fun: fn agent ->
          if agent == [:first] do
            {:running, [:second_running | agent]}
          else
            {:success, [:second_success | agent]}
          end
        end},
        %Action{fun: fn _ -> flunk("The third action in this select should not be executed") end}
      ]
    }

    assert {:running, select, [:second_running, :first] = state} = BehaviorTree.tick(select, [])
    assert {:success, _select, [:second_success, :second_running, :first]} = BehaviorTree.tick(select, state)
  end

  test "halts and returns :failure when all nodes fail" do
    select = %Select{
      nodes: [
        %Action{fun: fn _ -> :failure end},
        %Action{fun: fn _ -> :failure end},
        %Action{fun: fn _ -> :failure end},
        %Action{fun: fn _ -> :failure end}
      ]
    }

    assert {:failure, _select, _state} = BehaviorTree.tick(select, %{})
  end
end

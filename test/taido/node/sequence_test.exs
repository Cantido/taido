defmodule Taido.Node.SequenceTest do
  use ExUnit.Case, async: true

  alias Taido.BehaviorTree
  alias Taido.Node.Sequence
  alias Taido.Node.Action

  test "stops on first action that fails" do
    sequence = %Sequence{
      nodes: [
        %Action{fun: fn _ -> :failure end},
        %Action{fun: fn _ -> flunk("The second action in this select should not be executed") end}
      ]
    }
    assert {:failure, _, _} = BehaviorTree.tick(sequence, nil)
  end

  test "restarts after a failure" do
    sequence = %Sequence{
      nodes: [
        %Action{fun: fn _ -> :failure end},
        %Action{fun: fn _ -> flunk("The second action in this select should not be executed") end}
      ]
    }
    assert {:failure, _, _} = BehaviorTree.tick(sequence, nil)
    assert {:failure, _, _} = BehaviorTree.tick(sequence, nil)
  end

  test "executes the second action if the first one succeeds" do
    sequence = %Sequence{
      nodes: [
        %Action{fun: fn _ -> :success end},
        %Action{fun: fn _ -> :failure end},
        %Action{fun: fn _ -> flunk("The third action in this select should not be executed") end}
      ]
    }

    assert {:failure, _, _} = BehaviorTree.tick(sequence, nil)
  end

  test "each action can update the agent" do
    sequence = %Sequence{
      nodes: [
        %Action{fun: fn {nil, nil} -> {:success, {:first, nil}} end},
        %Action{fun: fn {:first, nil} -> {:failure, {:first, :second}} end}
      ]
    }

    assert {:failure, _, {:first, :second}} = BehaviorTree.tick(sequence, {nil, nil})
  end

  test "halts and maintains a counter when an action returns :running" do
    sequence = %Sequence{
      nodes: [
        %Action{fun: fn _ -> {:success, [:first]} end},
        %Action{fun: fn agent ->
          if agent == [:first] do
            {:running, [:second_running | agent]}
          else
            {:failure, [:second_failure | agent]}
          end
        end},
        %Action{fun: fn _ -> flunk("The third action in this select should not be executed") end}
      ]
    }

    assert {:running, sequence, [:second_running, :first] = state} = BehaviorTree.tick(sequence, [])
    assert {:failure, _sequence, [:second_failure, :second_running, :first]} = BehaviorTree.tick(sequence, state)
  end

  test "halts and returns :success when all nodes succeed" do
    sequence = %Sequence{
      nodes: [
        %Action{fun: fn _ -> :success end},
        %Action{fun: fn _ -> :success end},
        %Action{fun: fn _ -> :success end},
        %Action{fun: fn _ -> :success end}
      ]
    }

    assert {:success, _select, _state} = BehaviorTree.tick(sequence, %{})
  end
end

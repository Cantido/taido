defmodule Taido.Node.Sequence do
  @moduledoc """
  A composite node of behavior trees that takes a series of actions until
  one fails, at which point this node is considered failed.
  """

  @enforce_keys [:nodes]
  defstruct [
    :nodes,
    current: 0
  ]

  defimpl Taido.BehaviorTree do
    alias Taido.BehaviorTree

    def tick(sequence, state) do
      Enum.drop(sequence.nodes, sequence.current)
      |> Enum.reduce_while({:success, sequence, state}, fn node, {_status, sequence, state} ->
        case BehaviorTree.tick(node, state) do
          {:success, new_node, new_state} ->
            new_sequence =
              sequence
              |> Map.update!(:nodes, fn nodes ->
                List.replace_at(nodes, sequence.current, new_node)
              end)
              |> Map.update!(:current, fn current ->
                if current + 1 >= Enum.count(sequence.nodes) do
                  0
                else
                  current + 1
                end
              end)

            {:cont, {:success, new_sequence, new_state}}
          {:running, new_node, new_state} ->
            new_sequence =
              sequence
              |> Map.update!(:nodes, fn nodes ->
                List.replace_at(nodes, sequence.current, new_node)
              end)

            {:halt, {:running, new_sequence, new_state}}
          {:failure, new_node, new_state} ->
            new_sequence =
              sequence
              |> Map.update!(:nodes, fn nodes ->
                List.replace_at(nodes, sequence.current, new_node)
              end)
              |> Map.put(:current, 0)

            {:halt, {:failure, new_sequence, new_state}}
        end
      end)

    end

    def handle_message(sequence, message) do
      Map.update!(sequence, :nodes, fn nodes ->
        Enum.map(nodes, fn node ->
          Taido.BehaviorTree.handle_message(node, message)
        end)
      end)
    end

    def terminate(sequence) do
      Map.update!(sequence, :nodes, fn nodes ->
        Enum.map(nodes, fn node ->
          Taido.BehaviorTree.terminate(node)
        end)
      end)
    end
  end
end

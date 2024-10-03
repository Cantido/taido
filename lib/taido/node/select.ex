defmodule Taido.Node.Select do
  @moduledoc """
  A composite node of behavior trees that takes a series of actions until
  one succeeds, at which point this node is considered successful.
  """

  @enforce_keys [:nodes]
  defstruct [
    :nodes,
    current: 0
  ]


  defimpl Taido.BehaviorTree do
    alias Taido.BehaviorTree

    def tick(select, state) do
      Enum.drop(select.nodes, select.current)
      |> Enum.reduce_while({:success, select, state}, fn node, {_status, select, state} ->
        case BehaviorTree.tick(node, state) do
          {:success, new_node, new_state} ->
            new_select =
              select
              |> Map.update!(:nodes, fn nodes ->
                List.replace_at(nodes, select.current, new_node)
              end)
              |> Map.put(:current, 0)

            {:halt, {:success, new_select, new_state}}
          {:running, new_node, new_state} ->
            new_select =
              select
              |> Map.update!(:nodes, fn nodes ->
                List.replace_at(nodes, select.current, new_node)
              end)

            {:halt, {:running, new_select, new_state}}
          {:failure, new_node, new_state} ->
            new_select =
              select
              |> Map.update!(:nodes, fn nodes ->
                List.replace_at(nodes, select.current, new_node)
              end)
              |> Map.update!(:current, fn current ->
                if current + 1 >= Enum.count(select.nodes) do
                  0
                else
                  current + 1
                end
              end)

            {:cont, {:failure, new_select, new_state}}
        end
      end)

    end

    def handle_message(select, message) do
      Map.update!(select, :nodes, fn nodes ->
        Enum.map(nodes, fn node ->
          Taido.BehaviorTree.handle_message(node, message)
        end)
      end)
    end

    def terminate(select) do
      Map.update!(select, :nodes, fn nodes ->
        Enum.map(nodes, fn node ->
          Taido.BehaviorTree.terminate(node)
        end)
      end)
    end
  end
end

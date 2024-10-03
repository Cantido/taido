defmodule Taido.Node.Inverter do
  @enforce_keys [:node]
  defstruct [:node]

  defimpl Taido.BehaviorTree do
    def tick(inverter, state) do
      case Taido.BehaviorTree.tick(inverter.node, state) do
        {:success, new_node, new_state} ->
          {:failure, new_node, new_state}

        {:running, new_node, new_state} ->
          {:running, new_node, new_state}

        {:failure, new_node, new_state} ->
          {:success, new_node, new_state}
      end
    end

    def handle_message(inverter, message) do
      Taido.BehaviorTree.handle_message(inverter.node, message)
    end

    def terminate(inverter) do
      Taido.BehaviorTree.terminate(inverter.node)
    end
  end
end

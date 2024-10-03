defmodule Taido.Node.Condition do
  @enforce_keys [:predicate]
  defstruct [:predicate]

  defimpl Taido.BehaviorTree do
    def tick(node, state) do
      if node.predicate.(state) do
        {:success, node, state}
      else
        {:failure, node, state}
      end
    end

    def handle_message(condition, _message) do
      condition
    end

    def terminate(condition) do
      condition
    end
  end
end

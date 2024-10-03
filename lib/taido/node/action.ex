defmodule Taido.Node.Action do
  @enforce_keys [:fun]
  defstruct [:fun]

  defimpl Taido.BehaviorTree do
    def tick(action, state) do
      case action.fun.(state) do
        :success ->
          {:success, action, state}
        {:success, new_state} ->
          {:success, action, new_state}
        :running ->
          {:running, action, state}
        {:running, new_state} ->
          {:running, action, new_state}
        :failure ->
          {:failure, action, state}
        {:failure, new_state} ->
          {:failure, action, new_state}
      end
    end

    def handle_message(action, _message) do
      action
    end

    def terminate(action) do
      action
    end
  end
end

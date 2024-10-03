defmodule Taido.Node.AsyncAction do
  @enforce_keys [:fun]
  defstruct [:fun, :task, :result, has_result: false]

  defimpl Taido.BehaviorTree do
    require Logger

    def tick(node, state) do
      cond do
        node.task == nil ->
          task = Task.async(fn -> node.fun.(state) end)
          {:running, %{node | task: task}, state}

        node.has_result ->
          handle_result(node, node.result, state)

        node.task ->
          case Task.yield(node.task, 10) do
            {:ok, result} ->
              handle_result(node, result, state)

            nil ->
              {:running, node, state}

            # Explicitly not handling the {:exit, reason} signal,
            # I want the process to crash if the task has crashed
          end
      end
    end

    def handle_message(action, {ref, result}) do
      if action.task && action.task.ref == ref do
        %{action | has_result: true, result: result}
      else
        action
      end
    end

    def handle_message(action, _message) do
      action
    end

    defp handle_result(node, result, state) do
      case result do
        :success ->
          {:success, %{node | task: nil, result: nil, has_result: false}, state}

        {:success, new_state} ->
          {:success, %{node | task: nil, result: nil, has_result: false}, new_state}

        :failure ->
          {:failure, %{node | task: nil, result: nil, has_result: false}, state}

        {:failure, new_state} ->
          {:failure, %{node | task: nil, result: nil, has_result: false}, new_state}
      end
    end

    def terminate(action) do
      if action.task do
        Task.shutdown(action.task)
        %{action | task: nil, result: nil, has_result: false}
      else
        action
      end
    end
  end
end

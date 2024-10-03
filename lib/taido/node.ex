defmodule Taido.Node do
  @moduledoc """
  Nodes for `Taido`'s behavior trees.

  Leaf nodes:
  - `condition/1`
  - `action/1`

  Asynchronous leaf nodes:
  - `async_action/1`

  Composite nodes:
  - `select/1`
  - `sequence/1`

  Decorators:
  - `invert/1`
  """

  alias Taido.Node.{
    Action,
    AsyncAction,
    Condition,
    Inverter,
    Select,
    Sequence
  }

  def condition(predicate) when is_function(predicate, 1) do
    %Condition{predicate: predicate}
  end

  def action(fun) when is_function(fun, 1) do
    %Action{fun: fun}
  end

  def async_action(fun) when is_function(fun, 1) do
    %AsyncAction{fun: fun}
  end

  def select(nodes) when is_list(nodes) do
    %Select{nodes: nodes}
  end

  def sequence(nodes) when is_list(nodes) do
    %Sequence{nodes: nodes}
  end

  def invert(node) do
    %Inverter{node: node}
  end
end

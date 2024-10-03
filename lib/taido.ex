defmodule Taido do
  @moduledoc """
  `Taido` is a library for building and executing behavior trees in Elixir.

  First, build your tree using functions from the `Taido.Node` module.
  Here's an example of a behavior tree for a spaceship undocking from a
  space station and traveling to another waypoint.

      alias Taido.Node

      # At its highest level, we have two steps: undock, and navigate.
      # A sequence executes each of its children in order until
      # one fails.
      Node.sequence([

        # We want to undock, but it is possible that we are already undocked.
        # A `select` node, also known as a fallback, executes its children
        # in order until one of them succeeds.
        Node.select([

          # If you want to make your behavior tree more modular, decorator
          # nodes like `invert` allow you to flip the result of another node.
          # Here, we will use it to flip a `docked?` condition, so that
          # this step will succeed if we are undocked.
          # If it succeeds, this node's parent will not execute the subsequent
          # children, because it is a select node.
          Node.invert(

            # A condition node takes a boolean function, and succeeds if it
            # returns `true`, else it fails.
            # This node will succeed if the ship is docked.
            Node.condition(fn state ->
              state.ship.docked?
            end)
          ),

          # Finally, we do something to affect the world. The `action` node
          # gives you the tree's state object, and lets you modify it, then
          # lets you return a success or failure status of your own.
          # This will actually undock our ship, but only if the preceding
          # child didn't succeed, because they're both inside a `select` node.
          Node.action(fn state ->
            {:ok, ship} = Spaceships.undock(state.ship)

            {:success, Map.put(state, :ship, ship)}
          end)

          # Notice that our `select` node ends here.
        ]),

        # The goal of this entire tree, we navigate. Since this node is
        # a child of a `sequence` node, it gets executed only if its preceding
        # sibling nodes all succeed.
        Node.action(fn state ->
          {:ok, ship} = Spaceships.navigate(state.ship, "MARS")

          {:success, Map.put(state, :ship, ship)}
        end)
      ])

  Then you can execute the tree with `Taido.tick/2`.
  This will evaluate every node in order until either the tree was fully
  evaluated, or until one of the nodes returned a `:running` status.

      state = %{ship: Spaceships.new()}

      {status, updated_tree, updated_state} = Taido.tick(tree, state)

  Two important concepts in `Taido` are _state_ and _status_.
  - Taido treats state similarly to a `GenServer`'s state.
    Every time a behavior tree is evaluated, you must provide a `state`
    variable. This can be whatever data type you want; Taido only passes it
    into each node in the tree so that you can update it, and returns the
    updated state to you.
  - A node returns a status of either `:success`, `:failure`, or `:running`.
    They _can_ mean the same thing as Elixir's `:ok` or `:error` tuples,
    however they are mainly just feedback that a node gives to its parent,
    and eventually to you.

  See `Taido.Node` for the nodes provided by this library.
  You can also create your own node by implementing the `Taido.BehaviorTree`
  protocol.

  Taido's behavior tree nodes are structs, and the `Taido.tick/2` function
  is pure and runs in a single process, so the only side-effects are the ones
  you bring with you.

  ## Asynchronous nodes

  Asynchronous nodes are available, like `Taido.Node.async_action/1`.
  That node runs your action in a `Task` and immediately returns `:running`,
  which causes the behavior tree to stop evaluating, saving its place to
  resume later. Every time you run `Taido.tick/2`, the task is checked,
  and if it is done, its result is fetched, and the tree continues evaluating
  like normal.

  > #### Warning {: .warning}
  >
  > If you are running a behavior tree inside of anything like a `GenServer`,
  > which automatically await tasks, you must forward messages sent to the
  > `GenServer` to `Taido.handle_message/2`. Otherwise, the tasks in your
  > behavior tree will never be completed. It's as simple as this:
  >
  >     def handle_info(msg, state) do
  >       Taido.handle_message(state.behavior_tree, msg)
  >     end
  """

  @doc """
  Evaluate the behavior tree.

  Returns a tuple of `{status, updated_tree, your_state}`.
  Make sure to save the `updated_tree` somewhere, especially if you are using
  asynchronous nodes, because you must keep track of which tasks are
  currently waiting to be checked.
  """
  defdelegate tick(tree, state), to: Taido.BehaviorTree

  @doc """
  Handle a process message.

  You will only need to use this function if you are ticking asynchronous
  nodes in a context that automatically awaits tasks, like inside
  a `GenServer`. In that case, you must forward the `GenServer`'s messages
  to `Taido` like this:

      def handle_info(msg, state) do
        Taido.handle_message(state.behavior_tree, msg)
      end
  """
  defdelegate handle_message(tree, message), to: Taido.BehaviorTree

  @doc """
  Terminates all asynchronous tasks in the behavior tree.
  """
  defdelegate terminate(tree), to: Taido.BehaviorTree
end

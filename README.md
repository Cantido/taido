# Taido

[Behavior trees](https://en.wikipedia.org/wiki/Behavior_tree_(artificial_intelligence,_robotics_and_control))
for Elixir.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `taido` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:taido, "~> 0.1.0"}
  ]
end
```

The docs can be found at <https://hexdocs.pm/taido>.

## Usage

Here's an example tree that undocks a spaceship from a station and then navigates to another waypoint.

```elixir
defmodule SpaceshipBehaviors do
  alias Taido.Node

  def navigate(waypoint) do
    Node.sequence([
      Node.select([
        Node.invert(
          Node.condition(fn state ->
            state.ship.docked?
          end)
        ),

        Node.action(fn state ->
          {:ok, ship} = Spaceships.undock(state.ship)

          {:success, Map.put(state, :ship, ship)}
        end)
      ]),

      Node.action(fn state ->
        {:ok, ship} = Spaceships.navigate(state.ship, waypoint)

        {:success, Map.put(state, :ship, ship)}
      end)
    ])
  end
end
```

The evaluate the tree like this:

```elixir
state = %{ship: Spaceships.new()}

{status, updated_tree, updated_state} = Taido.tick(tree, state)
```

For details, see the [HexDocs].

[HexDocs]: https://hexdocs.pm/taido

## License

Copyright (C) 2024 Rosa Richter

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

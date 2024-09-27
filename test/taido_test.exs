defmodule TaidoTest do
  use ExUnit.Case
  doctest Taido

  test "greets the world" do
    assert Taido.hello() == :world
  end
end

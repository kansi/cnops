defmodule CnopsTest do
  use ExUnit.Case
  doctest Cnops

  test "greets the world" do
    assert Cnops.hello() == :world
  end
end

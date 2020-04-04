defmodule DummyTestTest do
  use ExUnit.Case
  doctest DummyTest

  test "greets the world" do
    assert DummyTest.hello() == :world
  end
end

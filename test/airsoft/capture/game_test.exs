defmodule Airsoft.Capture.GameTest do
  use ExUnit.Case
  alias Airsoft.Capture.Game

  @game_options [flags: [:a, :b, :c]]

  describe "capture/3" do
    test "sets the capturing team of a flag" do
      state =
        @game_options
        |> Game.start()
        |> Game.capture(:a, :red)

      flag = Map.get(state.flags, :a)
      assert flag == :red
    end

    test "it neutralizes a flag" do
      state =
        @game_options
        |> Game.start()
        |> Game.capture(:a, :red)
        |> Game.capture(:a, :blue)

      flag = Map.get(state.flags, :a)
      assert flag == :neutral
    end

    test "it remains when re-capturing an own flag" do
      state =
        @game_options
        |> Game.start()
        |> Game.capture(:a, :red)
        |> Game.capture(:a, :red)

      flag = Map.get(state.flags, :a)
      assert flag == :red
    end
  end
end

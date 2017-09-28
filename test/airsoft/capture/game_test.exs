defmodule Airsoft.Capture.GameTest do
  use ExUnit.Case
  alias Airsoft.Capture.Game

  @game_options [points: [:a, :b, :c]]

  describe "capture/3" do
    test "sets the capturing team of a point" do
      state =
        @game_options
        |> Game.start()
        |> Game.capture(:a, :red)

      point = Map.get(state.points, :a)
      assert point == :red
    end

    test "it neutralizes a point" do
      state =
        @game_options
        |> Game.start()
        |> Game.capture(:a, :red)
        |> Game.capture(:a, :blue)

      point = Map.get(state.points, :a)
      assert point == :neutral
    end

    test "it remains when re-capturing an own point" do
      state =
        @game_options
        |> Game.start()
        |> Game.capture(:a, :red)
        |> Game.capture(:a, :red)

      point = Map.get(state.points, :a)
      assert point == :red
    end
  end
end

defmodule Airsoft.Capture.Game do
  alias Airsoft.Capture.Point

  @teams [:red, :blue]

  # Time in seconds, that the team will get a point when holing one single flag.
  @default_time_per_point 5

  # Describes the time in which the team gains points when they have 100% of the points.
  @default_time_max_speed 0.5

  defmodule State do
    defstruct [
      points: %{},
      teams: %{},
      time_per_point: @default_time_per_point,
      time_max_speed: @default_time_max_speed,
      last_capture: nil
    ]
  end

  @doc """
  Starts a new game
  """
  def start(opts \\ []) do
    points = Keyword.get(opts, :points, [])
    time_per_point = Keyword.get(opts, :time_per_point, @default_time_per_point)
    time_max_speed = Keyword.get(opts, :time_max_speed, @default_time_max_speed)

    %State{
      time_per_point: time_per_point,
      time_max_speed: time_max_speed,
      points: Enum.reduce(points, %{}, fn point, acc ->
        Map.put(acc, point, :neutral)
      end),
      teams: Enum.reduce(@teams, %{}, fn team, acc ->
        Map.put(acc, team, 0)
      end)
    }
  end

  @doc """
  Captures a point by a given team.
  If the point is already captured by another team, it will be neutralised first.
  It also updates the scores of all teams and resets the capture timer.
  """
  def capture(game, point_id, team) do
    %State{game |
      points: Map.update!(game.points, point_id, fn point ->
        case point do
          :neutral -> team
          ^team -> team
          other -> :neutral
        end
      end),
      teams: Map.new(game.teams, fn {id, _} ->
        {id, team_score(game, id)}
      end),
      last_capture: :os.system_time(:second)
    }
  end

  @doc """
  Calculates the points of a team.
  """
  def team_score(%State{last_capture: last_capture}, _) when is_nil(last_capture), do: 0
  def team_score(game, team) do
    bonus_per_point = (game.time_per_point - game.time_max_speed) / (game.time_per_point - 1)

    captured_points = Enum.count(Map.values(game.points), fn point -> point == team end)
    current_score = Map.get(game.teams, team)
    passed_time = :os.system_time(:second) - game.last_capture

    if captured_points > 0 do
      seconds_per_point = game.time_per_point - ((captured_points - 1) * bonus_per_point)
      current_score + (passed_time / seconds_per_point)
    else
      current_score
    end
  end
end

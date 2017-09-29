defmodule Airsoft.Capture.Game do
  alias Airsoft.Capture.Point

  @teams [:red, :blue]

  # Time in seconds, that the team will get a point when holing one single flag.
  @default_time_per_point 5

  # Describes the time in which the team gains points when they have 100% of the flags.
  @default_time_max_speed 0.5

  defmodule State do
    defstruct [
      flags: %{},
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
    flags = Keyword.get(opts, :flags, [])
    time_per_point = Keyword.get(opts, :time_per_point, @default_time_per_point)
    time_max_speed = Keyword.get(opts, :time_max_speed, @default_time_max_speed)

    %State{
      time_per_point: time_per_point,
      time_max_speed: time_max_speed,
      flags: Enum.reduce(flags, %{}, fn flag, acc ->
        Map.put(acc, flag, :neutral)
      end),
      teams: Enum.reduce(@teams, %{}, fn team, acc ->
        Map.put(acc, team, 0.0)
      end)
    }
  end

  @doc """
  Captures a point by a given team.
  If the point is already captured by another team, it will be neutralised first.
  It also updates the scores of all teams and resets the capture timer.
  """
  def capture(game, flag, team) do
    %State{game |
      flags: Map.update!(game.flags, flag, fn flag_team ->
        case flag_team do
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
    bonus_per_flag = (game.time_per_point - game.time_max_speed) / (map_size(game.flags) - 1)

    captured_flags = Enum.count(game.flags, fn {_, flag_team} -> flag_team == team end)
    passed_time = :os.system_time(:second) - game.last_capture
    current_points = Map.get(game.teams, team)

    if captured_flags > 0 do
      seconds_per_point = game.time_per_point - ((captured_flags - 1) * bonus_per_flag)
      current_points + (passed_time / seconds_per_point)
    else
      current_points
    end
  end
end

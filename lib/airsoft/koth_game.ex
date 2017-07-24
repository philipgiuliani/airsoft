defmodule Airsoft.KOTHGame do
  @default_time 10 * 60
  @default_teams [:red, :blue]

  defmodule State do
    defstruct [
      start_ms: nil,
      last_event: {:neutral, 0},
      teams: %{}
    ]
  end

  @doc """
  Starts a new game
  """
  def start(opts \\ []) do
    time = Keyword.get(opts, :time, @default_time)
    teams = Keyword.get(opts, :teams, @default_teams)

    %State{
      start_ms: :os.system_time(:millisecond),
      teams: Map.new(teams, &({&1, time}))
    }
  end

  @doc """
  Returns the team thats currently capturing.
  """
  def current_team(state), do: elem(state.last_event, 0)

  @doc """
  Returns the remaining time of a given team.
  """
  def remaining_time(%State{last_event: {team, last_event_time}, teams: teams}, team) do
    now = :os.system_time(:second)
    Map.get(teams, team) - (now - last_event_time)
  end
  def remaining_time(state, team), do: Map.get(state.teams, team)

  @doc """
  Sets the current capturing team.
  """
  def capture(game, team) do
    teams = update_times(game.last_event, game.teams)

    %State{game |
      last_event: {team, :os.system_time(:second)},
      teams: teams
    }
  end

  # Updates the times of the teams
  defp update_times({:neutral, _event_time}, teams), do: teams
  defp update_times({team, event_time}, teams) do
    now = :os.system_time(:second)

    Map.update!(teams, team, fn remaining_time ->
      remaining_time - (now - event_time)
    end)
  end
end

defmodule Airsoft.Capture.Server do
  use GenServer
  alias Airsoft.Capture.Game

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end
  def capture(pid, flag, team), do: GenServer.cast(pid, {:capture, flag, team})

  def team_score(pid, team), do: GenServer.call(pid, {:team_score, team})

  # GenServer callbacks

  def init(opts) do
    {:ok, Game.start(opts)}
  end

  def handle_cast({:capture, flag, team}, game) do
    {:noreply, Game.capture(game, flag, team)}
  end

  def handle_call({:team_score, team}, _from, game) do
    {:reply, Game.team_score(game, team), game}
  end
end

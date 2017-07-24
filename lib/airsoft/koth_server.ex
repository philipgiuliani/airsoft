defmodule Airsoft.KOTHServer do
  use GenServer
  alias Airsoft.KOTHGame

  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, options, [])
  end

  def capture(pid, team), do: GenServer.cast(pid, {:capture, team})

  def current_team(pid), do: GenServer.call(pid, :current_team)

  def remaining_time(pid, team), do: GenServer.call(pid, {:remaining_time, team})

  # Callbacks

  def init(options) do
    {:ok, KOTHGame.start(options)}
  end

  def handle_cast({:capture, team}, state) do
    {:noreply, KOTHGame.capture(state, team)}
  end

  def handle_call(:current_team, _from, state) do
    {:reply, KOTHGame.current_team(state), state}
  end

  def handle_call({:remaining_time, team}, _from, state) do
    {:reply, KOTHGame.remaining_time(state, team), state}
  end
end

defmodule KOTHServer do
  use GenServer
  alias ElixirALE.GPIO

  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, options, [])
  end

  def init(options) do
    game = KOTHGame.start(options)
    {:ok, game}
  end
end

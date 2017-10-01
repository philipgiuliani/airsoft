defmodule Airsoft.UART do
  use GenServer
  require Logger

  @name __MODULE__

  def start_link(port, speed) do
    GenServer.start_link(__MODULE__, {port, speed}, name: @name)
  end

  def init({port, speed}) do
    {:ok, uart_pid} = Nerves.UART.start_link()

    :ok = Nerves.UART.open(
      uart_pid,
      port,
      speed: speed,
      active: true,
      framing: {Nerves.UART.Framing.Line, separator: "\r\n"}
    )

    {:ok, []}
  end

  def handle_info({:nerves_uart, _port, message}, state) do
    Logger.debug "Message received: #{to_string(message)}"
    {:noreply, state}
  end
end

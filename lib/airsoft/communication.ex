defmodule Airsoft.Communication do
  use GenServer
  require Logger

  def start_link(port, speed) do
    GenServer.start_link(__MODULE__, {port, speed}, name: __MODULE__)
  end

  def init({port, speed}) do
    {:ok, uart_pid} = Nerves.UART.start_link()

    :ok = Nerves.UART.open(
      uart_pid,
      port,
      speed: speed,
      active: true,
      rx_framing_timeout: 1000,
      framing: {Nerves.UART.Framing.Line, separator: "\r\n"}
    )

    {:ok, uart_pid}
  end

  def handle_info({:nerves_uart, _port, message}, state) do
    <<from::size(8), to::size(8), message_id::size(8), command::size(8), _::binary>> = message
    Logger.debug "String: #{to_string(message)}"
    {:noreply, state}
  end
end

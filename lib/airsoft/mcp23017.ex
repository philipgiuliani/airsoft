defmodule Airsoft.MCP23017 do
  use GenServer
  use Bitwise
  alias ElixirALE.I2C

  @iodir_a 0x00
  @iodir_b 0x01
  @gpio_a 0x12
  @gpio_b 0x13
  @gppu_a 0x0C
  @gppu_b 0x0D

  defmodule State do
    defstruct [
      pid: nil,
      pullup_a: 0x00,
      pullup_b: 0x00,
      values_a: 0x00,
      values_b: 0x00,
      mode_a: 0xff,
      mode_b: 0xff
    ]
  end

  @doc """
  Initializes a MCP23017 chip.
  """
  def start_link(name, address \\ 0x20, opts \\ []) do
    GenServer.start_link(__MODULE__, {name, address}, [])
  end

  @doc """
  Sets a pin to input or output.
  """
  def setup(pid, pin, value), do: GenServer.cast(pid, {:setup, pin, value})

  @doc """
  Enables the internal pull up resistor on a pin.
  """
  def pullup(pid, pin, value), do: GenServer.cast(pid, {:pullup, pin, value})

  @doc """
  Sets a output to high or low.
  """
  def write(pid, pin, value), do: GenServer.cast(pid, {:write, pin, value})

  @doc """
  Returns the current value of a pin.
  """
  def read(pid, pin), do: GenServer.call(pid, {:read, pin})

  # Implementation

  def init({name, address}) do
    {:ok, pid} = I2C.start_link(name, address)
    {:ok, %State{pid: pid}}
  end

  def handle_cast({:setup, pin, value}, state) do
    {:noreply, state}
  end

  def handle_cast({:pullup, pin, value}, state) do
    {:noreply, state}
  end

  def handle_cast({:write, pin, value}, state) do
    {:noreply, state}
  end

  def handle_call({:read, pin}, _from, state) do
    {:reply, 0, state}
  end
end

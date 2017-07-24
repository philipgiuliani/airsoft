defmodule Airsoft.Application do
  use Application
  use Bitwise
  require Logger
  alias ElixirALE.I2C
  alias ElixirALE.GPIO

  @iodir_a 0x00
  @iodir_b 0x01
  @gpio_a 0x12
  @gpio_b 0x13
  @gppu_a 0x0C
  @gppu_b 0x0D
  # @olat_a 0x14
  # @olat_b 0x15

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Airsoft.KOTHServer, [])
    ]

    opts = [strategy: :one_for_one, name: Airsoft.Supervisor]
    Supervisor.start_link(children, opts)

    # IC2 configuration
    {:ok, pid} = I2C.start_link("i2c-1", 0x20)
    I2C.write(pid, <<@iodir_a, 0xff>>) # Bank A: Set all to inputs
    I2C.write(pid, <<@gppu_a, 0xff>>) # Bank A: Enable pull up resistors

    I2C.write(pid, <<@iodir_b, 0xff>>) # Bank B: Set all to inputs
    I2C.write(pid, <<@gppu_b, 0xff>>) # Bank B: Enable pull up resistors

    # Output
    {:ok, gpio_17} = GPIO.start_link(17, :output)
    GPIO.write(gpio_17, 1)

    spawn(fn -> read_inputs(pid) end)

    {:ok, self()}
  end

  def read_inputs(pid) do
    <<values_a>> = I2C.write_read(pid, <<@gpio_a>>, 1) # Bank A: Read
    <<values_b>> = I2C.write_read(pid, <<@gpio_b>>, 1) # Bank B: Write

    #Logger.debug "Bank A: #{values_a}"
    #Logger.debug "Bank B: #{values_b}"

    [128,64,32,16,8,4,2,1]
    |> Enum.with_index()
    |> Enum.map(fn {value, index} ->
      if (values_a &&& value) == 0 do
        Logger.debug "Button #{index+1} is pressed!"
      end
    end)

    #:timer.sleep(10)

    read_inputs(pid)
  end
end

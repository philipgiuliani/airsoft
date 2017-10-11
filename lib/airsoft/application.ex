defmodule Airsoft.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Airsoft.Communication, ["ttyAMA0", 115200])
    ]

    opts = [strategy: :one_for_one, name: Airsoft.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

defmodule Warehouse do
  use Application

  def start(_type, _args) do
    Warehouse.Supervisor.start_link()
  end
end

defmodule Tilewars.PlayerSup do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(name) do
    {:ok, pid } = DynamicSupervisor.start_child(Tilewars.PlayerSup, {Tilewars.Player, name})
    pid
  end

end

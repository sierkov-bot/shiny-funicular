defmodule Tilewars.GameServer do
  alias Tilewars.Game

  require Logger

  use GenServer, restart: :transient

  @worker_interval 250

  def start_link(state \\ %{}) do
    GenServer.start_link(__MODULE__, state, name: :server)
  end

  @impl true
  def init(state) do
    :timer.send_interval(@worker_interval, :work)
    {:ok, state}
  end

  @impl true
  def handle_info(:work, state) do
    Game.run()
    {:noreply, state}
  end
end

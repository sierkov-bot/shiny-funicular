defmodule TilewarsWeb.GameChannel do
  use TilewarsWeb, :channel

  require Logger

  @impl true
  def join("game:lobby", _payload, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_in("spawn", playername, socket) do
    # Tell the server we are ready to play
    GenServer.cast(PReg, {:add, playername})
    {:noreply, socket}
  end

  @impl true
  def handle_in("move", %{"name" => name, "direction" => direction}, socket) do
    player = GenServer.call(PReg, {:lookup, name})
    new_pos = Tilewars.Game.get_destination_pos(player.position, direction)
    if alive?(player), do: GenServer.call(player.pid, {:update_pos, new_pos})

    # More responsiveness
    Tilewars.Game.run()

    {:reply, :ok, socket}
  end

  @impl true
  def handle_in("attack", name, socket) do
    player = GenServer.call(PReg, {:lookup, name})

    if alive?(player), do: Tilewars.Game.make_attack(player)
    {:reply, :ok, socket}
  end

  defp alive?(player) do
    if player.status == :alive do
      true
    else
      false
    end
  end
end

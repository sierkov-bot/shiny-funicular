defmodule TilewarsWeb.GameChannel do
  use TilewarsWeb, :channel

  alias Tilewars.Game

  require Logger

  @impl true
  def join("game:lobby", _payload, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_in("spawn", playername, socket) do
    GenServer.cast(PReg, {:add, playername})
    {:noreply, socket}
  end

  @impl true
  def handle_in("move", %{"name" => name, "direction" => direction}, socket) do
    player = get_player(name)

    new_pos = Game.get_destination_pos(player.position, direction)

    # Cannot act if dead
    if alive?(player), do: GenServer.call(player.pid, {:update_pos, new_pos})

    # For more responsiveness
    Game.run()

    {:reply, :ok, socket}
  end

  @impl true
  def handle_in("attack", name, socket) do
    player = get_player(name)

    if alive?(player), do: Game.make_attack(player)
    {:reply, :ok, socket}
  end

  defp get_player(name) do
    GenServer.call(PReg, {:lookup, name})
  end

  defp alive?(player) do
    if player.status == :alive do
      true
    else
      false
    end
  end
end

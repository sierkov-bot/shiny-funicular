defmodule Tilewars.Player do
  use GenServer, restart: :temporary

  alias Tilewars.Game

  @respawn_time 5_000

  def start_link(player) do
    GenServer.start_link(__MODULE__, player)
  end

  @impl true
  def init(player) do
    # Get random position for spawn
    pos = Game.get_available_position()

    plr = %{name: player, position: pos, status: :alive, pid: self()}
    {:ok, plr}
  end

  @impl true
  def handle_call(:info, _from, player) do
    {:reply, player, player}
  end

  @impl true
  def handle_call({:update_pos, new_pos}, _from, player) do
    {:reply, player, Map.put(player, :position, new_pos)}
  end

  @impl true
  def handle_call(:kill, _from, player) do
    # Schedule respawn after death
    Process.send_after(self(), :respawn, @respawn_time, [])

    {:reply, player.status, Map.put(player, :status, :dead)}
  end

  @impl true
  def handle_info(:respawn, player) do
    reset = %{
      name: player.name,
      position: Game.get_available_position(),
      status: :alive,
      pid: self()
    }

    {:noreply, reset}
  end

end

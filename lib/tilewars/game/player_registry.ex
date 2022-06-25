defmodule Tilewars.PlayerRegistry do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(_opts) do
    st = %{}

    {:ok, st}
  end

  def handle_call(:all, _from, st) do
    # Poll player servers for theirs' positions and status
    players =
      Enum.map(Map.values(st), fn player ->
        GenServer.call(player.pid, :info)
      end)

    # Send them to client
    {:reply, players, st}
  end

  def handle_call({:lookup, name}, _from, st) do
    {_, plr } = Map.fetch(st, name)
    player = GenServer.call(plr.pid, :info)
    {:reply, player, st}
  end

  def handle_cast({:add, name}, st) do
    if Map.has_key?(st, name) do
      # Do nothing - player already exists
      {:noreply, st}
    else
      pid = Tilewars.PlayerSup.start_child(name)
      {:noreply, Map.put(st, name, %{name: name, position: [0, 0], pid: pid})}
    end
  end

  def get_player(name) do
    GenServer.call(PReg, {:lookup, name})
  end

end

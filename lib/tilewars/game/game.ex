defmodule Tilewars.Game do
  alias Tilewars.Constant
  alias TilewarsWeb.Endpoint

  def run() do
    # Get all players and their info(position, status)
    players =
      Enum.map(get_players(), fn v ->
        # No need to send PIDs to client
        Map.delete(v, :pid)
      end)

    # Build state map to send to clients
    response = %{players: players, walls: get_wall_tiles()}

    # Broadcast it to all sockets
    Endpoint.broadcast("game:lobby", "state", response)
  end

  @doc """
  Get a list of victims for killing
  """
  def get_enemy_positions(tiles, attacker) do
    players = get_players()

    # Get all enemies on map
    enemies =
      Enum.filter(players, fn player ->
        if player.name !== attacker.name do
          player
        end
      end)

    # Victims in vicinity
    victims =
      Enum.map(enemies, fn enemy ->
        if Enum.any?(tiles, fn tile ->
             enemy[:position] == tile && enemy[:status] == :alive
           end) do
          enemy
        end
      end)

    victims
  end

  @doc """
  Sends :kill to each victim - they'll be dead now.
  """
  def reap_victims(victims) do
    Enum.each(victims, fn v ->
      if v !== nil, do: GenServer.call(v.pid, :kill)
    end)
  end

  def make_attack(attacker) do
    aoe = get_attack_area(attacker.position)
    victims = get_enemy_positions(aoe, attacker)
    reap_victims(victims)
  end

  @doc """
  Get new position to move to. Return old position if new one is not valid.
  """
  def get_destination_pos(curr_pos, direction) do
    walkable_tiles = get_walkable_tiles()

    new_pos =
      cond do
        direction == Constant.direction().up ->
          [List.first(curr_pos), List.last(curr_pos) - 1]

        direction == Constant.direction().right ->
          [List.first(curr_pos) + 1, List.last(curr_pos)]

        direction == Constant.direction().down ->
          [List.first(curr_pos), List.last(curr_pos) + 1]

        direction == Constant.direction().left ->
          [List.first(curr_pos) - 1, List.last(curr_pos)]
      end

    # Check if new position can be walked on
    if Enum.any?(walkable_tiles, fn xy -> xy == new_pos end) do
      new_pos
    else
      curr_pos
    end
  end

  def get_walkable_tiles() do
    wall_tiles = get_wall_tiles()

    # Build a list of walkable coordinates.
    walkable_tiles =
      Enum.reduce(0..(Constant.grid().width - 1), [], fn x, x_acc ->
        x_acc ++
          Enum.reduce(0..(Constant.grid().width - 1), [], fn y, y_acc ->
            # check for walls here
            if Enum.any?(wall_tiles, fn xy -> xy == [x, y] end) do
              # add position and continue
              y_acc
            else
              [[x, y] | y_acc]
            end
          end)
      end)

    walkable_tiles
  end

  @doc """
  Get random walkable tile to spawn on.
  """
  def get_available_position() do
    walkable_tiles = get_walkable_tiles()
    Enum.random(walkable_tiles)
  end

  defp get_players() do
    GenServer.call(PReg, :all)
  end

  defp get_wall_tiles() do
    [
      [5, 6],
      [5, 7],
      [5, 8],
      [4, 2],
      [4, 3],
      [3, 3],
      [9, 5],
      [9, 4],
      [9, 3]
    ]
  end

  defp get_attack_area(pos) do
    pos_x = List.first(pos)
    pos_y = List.last(pos)

    attack_tiles =
      Enum.reduce((pos_x - 1)..(pos_x + 1), [], fn x, x_acc ->
        x_acc ++
          Enum.reduce((pos_y - 1)..(pos_y + 1), [], fn y, y_acc ->
            [[x, y] | y_acc]
          end)
      end)

    attack_tiles
  end
end

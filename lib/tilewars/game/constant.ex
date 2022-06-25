defmodule Tilewars.Constant do

  @direction %{
    up: 0,
    right: 1,
    down: 2,
    left: 3,
  }

  # Needs updating js if changed
  @grid %{
    width: 10,
    height: 10,
  }

  def direction, do: @direction
  def grid, do: @grid
end


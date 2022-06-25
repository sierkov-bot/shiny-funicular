defmodule TilewarsWeb.GameController do
  use TilewarsWeb, :controller

  # pick username with /game?user=
  def index(conn, %{"name" => name}) do
    render(conn, "gameview.html", name: name)
  end
end

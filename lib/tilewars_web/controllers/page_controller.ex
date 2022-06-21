defmodule TilewarsWeb.PageController do
  use TilewarsWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end

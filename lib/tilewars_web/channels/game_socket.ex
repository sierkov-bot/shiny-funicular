defmodule TilewarsWeb.GameSocket do
  use Phoenix.Socket

  channel "game:lobby", TilewarsWeb.GameChannel

  @impl true
  def connect(params, socket, _connect_info) do
    {:ok, assign(socket, :user_id, params["user_id"])}
  end

  @impl true
  def id(socket), do: "user_socket:#{socket.assigns.user_id}"
end

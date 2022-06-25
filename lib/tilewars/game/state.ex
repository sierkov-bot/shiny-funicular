defmodule Tilewars.State do

  defstruct cells: Enum.map(1..100, fn _ -> %{} end)

end


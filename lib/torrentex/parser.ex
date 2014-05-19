defmodule Torrentex.Parser do
  alias Torrentex.BEncoding

  def parse(content) do
    {data, []} = BEncoding.decode(content)
    data
  end
end

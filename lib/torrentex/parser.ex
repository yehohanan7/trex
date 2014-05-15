defmodule Torrentex.Parser do
  alias Torrentex.BEncoding

  def parse(content) do
    parsed_content = BEncoding.decode(content)    
  end
end

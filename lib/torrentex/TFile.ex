defmodule Torrentex.TFile do
  alias Torrentex.Parser

  def create(path) do
    path
    |> File.read
    |> (fn ({:ok, content}) -> content end).()
    |> String.codepoints
    |> Parser.parse
    |> (fn (content) -> %{name: path, content: content} end).()
  end

  def name (%{name: file_name}) do
    file_name
  end

  def content (%{content: file_content}) do
    file_content
  end

end

defmodule Torrent do
  defrecord File, name: nil, size: nil

  def new do
    File.new
  end

end

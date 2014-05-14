defmodule Torrentx.File do

  defrecordp :file, TorrentFile, path: nil, size: nil

  def new (path \\ "") do
    file(path: path)
  end

  def path(file(path: path)), do: path


end

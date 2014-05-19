defmodule Torrentex.Torrent do
  @moduledoc """
  Abstracts the .torrent file by exposing API needed to access every necessary
  information from the torrent file.
  """
  alias Torrentex.BEncoding

  def create(file) do
    file
    |> get_data
    |> :binary.bin_to_list
    |> BEncoding.decode
    |> as_tfile
  end

  def as_tfile({:dict, data}) do
    {:dict, info} = data["info"]
    piece_length = info["piece length"]; total_size = info["length"]

    %{
      :name              => info["name"],
      :hash              => info["filehash"],
      :size              => total_size,
      :number_of_pieces  => round(total_size / piece_length),
      :piece_length      => piece_length,
      :creation_date     => data["creation date"],
      :created_by        => data["created by"],
      :announce          => data["announce"],
      :announce_list     => Enum.map(elem(data["announce-list"], 1), fn {_k, [v]} -> v end),
      :info_hash         => BEncoding.encode(info)
    }
  end

  defp get_data(file) do
    {:ok, data} = File.read(file)
    data
  end

end

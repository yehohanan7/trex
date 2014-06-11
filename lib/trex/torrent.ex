defmodule Trex.Torrent do
  @moduledoc """
  Abstracts the .torrent file by exposing API needed to access every necessary
  information from the torrent file.
  """
  alias Trex.BEncoding

  def create(file) do
    file
    |> get_data
    |> :binary.bin_to_list
    |> BEncoding.decode
    |> as_tfile
  end

  def as_tfile({:dict, data}) do

    {:dict, info} = data["info"]
    piece_length = Dict.get(info, "piece length", 1)
    pieces = Dict.get(info, "pieces")

    %{
      :name              => Dict.get(info, "name", "downloaded"),
      :piece_length      => piece_length,
      :pieces            => pieces,
      :creation_date     => data["creation date"],
      :created_by        => data["created by"],
      :announce          => data["announce"],
      :announce_list     => Enum.map(elem(data["announce-list"], 1), fn {_k, [v]} -> v end),
      :info_hash         => :crypto.hash(:sha, BEncoding.encode(info)) |> Hex.encode,
      :files             => file_info(info)
    }
  end

  #Single file format
  def file_info(%{"length" => length} = info) do
    [%{:name => info["name"], :length => length}]
  end

  #Multi file format
  def file_info(info) do
    {:list, files} = info["files"]
    lc {:dict, file} inlist files, do: %{length: file["length"], path: hd(elem(file["path"], 1))}
  end

  defp get_data(file) do
    {:ok, data} = File.read(file)
    data
  end

end

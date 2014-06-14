defmodule Trex.Torrent do
  @moduledoc """
  Abstracts the .torrent file by exposing API needed to access every necessary
  information from the torrent file.
  """
  alias Trex.BEncoding
  import Trex.Lambda

  def create(file) do
    tfile = file
    |> get_data
    |> :binary.bin_to_list
    |> BEncoding.decode
    |> as_tfile
    Dict.put(tfile, :file_path, file)
  end

  def as_tfile({:dict, data}) do

    {:dict, info} = data["info"]
    piece_length = Dict.get(info, "piece length", 1)
    pieces = Dict.get(info, "pieces")
    info_hash = :crypto.hash(:sha, BEncoding.encode(info)) |> Hex.encode
    torrent_id = string_to_atom(info_hash)
                                                                  
    %{
      :id                => torrent_id,
      :name              => Dict.get(info, "name", "downloaded"),
      :piece_length      => piece_length,
      :pieces            => pieces,
      :creation_date     => data["creation date"],
      :created_by        => data["created by"],
      :announce          => data["announce"],
      :announce_list     => Enum.map(elem(data["announce-list"], 1), fn {_k, [v]} -> v end),
      :info_hash         => info_hash,
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
    Enum.map(files, fn 
         {:dict, file} -> %{length: file["length"], path: hd(elem(file["path"], 1))}
    end)

  end

  defp get_data(file) do
    {:ok, data} = File.read(file)
    data
  end

end

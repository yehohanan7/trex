defmodule Trex.Parser do
  alias Trex.BEncoding

  def parse(data) do
    BEncoding.decode(:binary.bin_to_list(data)) |> to_torrent
  end

  defp to_torrent(%{"info" => info} = data) do
    info_hash = info_hash(info)
    %{
      :id                => String.to_atom(info_hash),
      :name              => Dict.get(info, "name", "downloaded"),
      :piece_length      => info["piece length"],
      :pieces            => info["pieces"],
      :creation_date     => data["creation date"],
      :created_by        => data["created by"],
      :announce          => data["announce"],
      :announce_list     => Enum.map(data["announce-list"], fn [v] -> v end),
      :info_hash         => info_hash,
      :files             => file_info(info)
    }
  end

  #Single file format
  def file_info(%{"length" => length} = info) do
    [%{:name => info["name"], :length => length}]
  end

  #Multi file format
  def file_info(%{"files" => files}) do
    Enum.map(files, fn 
         file -> %{length: file["length"], path: file["path"]}
    end)
  end

  defp info_hash(info) do
    :crypto.hash(:sha, BEncoding.encode(info)) |> Hex.encode
  end

end

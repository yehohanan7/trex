defmodule Torrentex.TFile do
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
  end

  defp get_data(file) do
    {:ok, data} = File.read(file)
    data
  end

  defp extract(key, {:dict, data}) do
    data[key]
  end

  #External API
  def info(tfile) do
    {:dict, info_dict} = extract("info", tfile)
    info_dict
  end

  def name(tfile) do
    info(tfile)["name"]
  end

  def length(tfile) do
    info(tfile)["length"]
  end

  def hash(tfile) do
    info(tfile)["filehash"]
  end

  def piece_length(tfile) do
    info(tfile)["piece length"]
  end

  def total_size(tfile) do
    info(tfile)["length"]
  end

  def number_of_pieces(tfile) do
    round(total_size(tfile) / piece_length(tfile))
  end

  def announce_list(tfile) do
    {:list, announce_list} = extract("announce-list", tfile)
    Enum.map(announce_list, fn {_k, [v]} -> v end)
  end

  def announce(tfile) do
    extract("announce", tfile)
  end

  def creation_date(tfile) do
    extract("creation date", tfile)
  end

  def created_by(tfile) do
    extract("created by", tfile)
  end

  def info_hash(tfile) do

  end

end

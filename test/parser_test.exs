defmodule ParserTest do
  use ExUnit.Case
  import Trex.Parser

  test "parsing" do
    {:ok, data} = File.read("test/data/fifa.torrent")
    torrent = parse(data)
    assert(torrent[:id] == :"07afa600a8c3999c1725ffe01b1239037a3bfc14")
    assert(torrent[:name] == "FIFA.14.Multi13-RU.Repack.by.z10yded")
    assert(torrent[:info_hash] == "07afa600a8c3999c1725ffe01b1239037a3bfc14")
    assert(length(torrent[:files]) == 28)
  end


end

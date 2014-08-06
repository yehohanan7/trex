defmodule Trex do
  use Application
  alias Trex.Torrent
  alias Trex.Supervisor
  import Trex.Parser

  def version, do: 1.1

  def start(_,_) do
    IO.puts "Starting Trex supervisor..."
    HTTPotion.start
    Supervisor.start_link
  end

  #External APIs
  def download(file) do
    {:ok, data} = File.read("test/data/fifa.torrent")
    data |> parse |> Torrent.start
  end

end

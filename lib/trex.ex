defmodule Trex do
  use Application
  alias Trex.Torrent
  alias Trex.Supervisor
  alias Trex.BEncoding

  def version, do: 1.1

  def start(_,_) do
    IO.puts "Starting Trex supervisor..."
    :hackney.start
    Supervisor.start_link
  end

  #External APIs
  def download(file) do
    {:ok, data} = File.read(file)
    data |> :binary.bin_to_list |> BEncoding.decode |> Torrent.start
  end

end


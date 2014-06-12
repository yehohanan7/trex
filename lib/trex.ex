defmodule Trex do
  use Application.Behaviour
  alias Trex.Torrent
  alias Trex.Tracker
  alias Trex.Downloader
  alias Trex.Supervisor
  alias Trex.Url

  def version, do: 1.1

  @port 7771

  def start(_,_) do
    IO.puts "Starting Trex supervisor..."
    Supervisor.start_link
  end

  #External APIs
  defp start_trackers(torrent, peer) do
    for {url, index} <- Enum.with_index([torrent[:announce] | torrent[:announce_list]]) do
      case url do
        <<"http", _::binary>> -> Supervisor.start_tracker(:tcp, @port + index, Url.parse(url), peer)
        <<"udp", _::binary>>  -> Supervisor.start_tracker(:udp, @port + index, Url.parse(url), peer)
      end
    end
  end

  def download(file) do
    torrent = Torrent.create(file)
    peer = Supervisor.start_peer(torrent)
    start_trackers(torrent, peer)
  end

  def status do
    "Not yet implemented"
  end

end

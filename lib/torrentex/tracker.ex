defmodule Torrentex.Tracker do
  use GenServer.Behaviour
  alias Torrentex.Url

  #External API
  def start_link(udp_port, http_port) do
    :gen_server.start_link({:local, :tracker}, __MODULE__, [udp_port, http_port], [])
  end

  def track(torrent) do
    case torrent[:announce] do
      <<"http", _::binary>> -> :gen_server.call :tracker, {:track, :http, torrent}
      <<"udp", _::binary>>  -> :gen_server.call :tracker, {:track, :udp, torrent}
    end
  end

  #GenServer Callbacks
  def init(udp_port, http_port) do
    {:ok, udp_socket} = :gen_udp.open(udp_port, [:binary], {:active, true})
    {:ok, %{:udp_port => udp_port, :udp_socket => udp_socket}}
  end

  def handle_call({:track, :udp, torrent}, _from, state) do
    IO.inspect "sending announce request to #{torrent[:announce]}"
    {ok, socket} = :gen_udp.open(0, [:binary])
    [domain, port] = Url.host(torrent[:announce])
    :ok = :gen_udp.send(socket, domain, port, "data")
    IO.inspect "announce request sent!"
    {:reply, "tracking...", state}
  end

  def handle_call({:track, :http, torrent}, _from, state) do
    response = HTTPotion.get(torrent[:announce] <> "?info_hash=#{}&peer_id=12345678911234123457&port=7777&uploaded=0&downloaded=0&left=#{torrent[:size]}")
    {:reply, response, state}
  end

  def handle_call(:status, _from, state) do
    {:reply, "status", state}
  end


end

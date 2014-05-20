defmodule Torrentex.UDPTracker do
  use GenServer.Behaviour
  alias Torrentex.Url

  #External API
  def start_link(port) do
    :gen_server.start_link({:local, :tracker}, __MODULE__, port, [])
  end

  def track(torrent) do
    :gen_server.cast :tracker, {:track, torrent}
  end

  #GenServer Callbacks
  def init(port) do
    {:ok, socket} = :gen_udp.open(port, [:binary, {:active, true}])
    {:ok, %{:socket => socket}}
  end

  def handle_cast({:track, torrent}, state) do
    IO.inspect "sending announce request to #{torrent[:announce]}"
    send_announce_request(state[:socket], torrent)
    IO.inspect "announce request sent!"
    {:noreply, state}
  end

  def handle_call(:status, _from, state) do
    {:reply, "status", state}
  end

  def handle_info({:udp, _, _ip, _port, packet}, state) do
    IO.inspect "Data recieved on udp socket.."
    {:noreply, state}
  end

  def send_announce_request(socket, torrent) do
    [domain, port] = Url.host(torrent[:announce])
    :ok = :gen_udp.send(socket, domain, port, "data")
  end

end

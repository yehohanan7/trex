defmodule Torrentex.UDPTracker do
  use GenServer.Behaviour
  alias Torrentex.Url

  @actions %{:connect   => 0,
             :announce  => 1,
             :scrape    => 2,
             :error     => 3}

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
    IO.inspect "sending connect request to #{torrent[:announce]}"
    send_message({state[:socket], torrent}, :connect)
    # IO.inspect "sending announce request to #{torrent[:announce]}"
    # send_message({state[:socket], torrent}, :announce)
    # IO.inspect "announce request sent!"
    {:noreply, state}
  end

  def handle_call(:status, _from, state) do
    {:reply, "status", state}
  end

  #Utilities
  defp generate_transaction_id do
    :crypto.rand_bytes(4)
  end

  #Outgoing messages
  defp send_message({socket, torrent}, :announce) do
    [domain, port] = Url.host(torrent[:announce])
    :ok = :gen_udp.send(socket, domain, port, "data")
  end

  defp send_message({socket, torrent}, :connect) do
    [domain, port] = Url.host(torrent[:announce])
    :ok = :gen_udp.send(socket, domain, port, <<4497486125440::64,@actions[:connect]::32, generate_transaction_id::binary>>)
  end


  #Incoming messages from socket
  def handle_info({:udp, _, _ip, _port, packet}, state) do
    IO.inspect "Data recieved on udp socket.."
    IO.inspect packet
    {:noreply, state}
  end

end

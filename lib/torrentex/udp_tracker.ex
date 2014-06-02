defmodule Torrentex.UDPTracker do
  @behaviour :gen_fsm
  alias Torrentex.Url
  alias Torrentex.Tracker.Messages, as: Messages


  #External API
  def start_link(port, torrent) do
    :gen_fsm.start_link(__MODULE__, [port, torrent], [])
  end

  #GenServer Callbacks
  def init([port, torrent]) do
    {:ok, socket} = :gen_udp.open(port, [:binary, {:active, true}])
    {:ok, :initialized, %{:socket => socket, :torrent => torrent}, 0}
  end

  def terminate(_reason, _statename, _state) do
    :ok
  end

  #States
  def initialized(event, %{:socket => socket, :torrent => torrent} = state) do
    [domain, port] = Url.host(torrent[:announce])
    transaction_id = generate_transaction_id

    :ok = :gen_udp.send(socket, domain, port, Messages.connect_request(transaction_id))
    {:next_state, :connecting, Dict.put(state, :transaction_id, transaction_id)}
  end
  

  #Socket message handlers
  def packet_recieved(:connecting, packet, %{:socket => socket, :torrent => torrent} = state) do
    {connection_id: connection_id} = Messages.parse(packet, state[:transaction_id])
    IO.inspect "connected!"
    [domain, port] = Url.host(torrent[:announce])
    :ok = :gen_udp.send(socket, domain, port, Messages.announce_request(state[:transaction_id], connection_id))

    {:next_state, :announcing, Dict.put(state, :connection_id, connection_id)}
  end

  def packet_recieved(:announcing, packet, state) do
    IO.inspect "announce response received"
    {:next_state, :connected, state}
  end

  #Incoming messages from socket
  def handle_info({:udp, _, _ip, _port, packet}, state_name, state) do
    IO.inspect "packet recieved!!"
    packet_recieved(state_name, packet, state)
  end

  #Utilities
  defp generate_transaction_id do
    :crypto.rand_bytes(4)
  end

end

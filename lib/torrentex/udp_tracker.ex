defmodule Torrentex.UDPTracker do
  use GenServer.Behaviour
  alias Torrentex.Url

  @actions %{:connect   => 0,
             :announce  => 1,
             :scrape    => 2,
             :error     => 3}

  #External API
  def start_link(port, torrent) do
    :gen_server.start_link(__MODULE__, [port, torrent], [])
  end

  #GenServer Callbacks
  def init([port, torrent]) do
    {:ok, socket} = :gen_udp.open(port, [:binary, {:active, true}])
    {:ok, %{:socket => socket, :torrent => torrent}, 0}
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

  #initializer
  def handle_info(:timeout, %{:socket => socket, :torrent => torrent} = state) do
    send_message({socket, torrent}, :connect)
    {:noreply, state}
  end

  #Incoming messages from socket
  def handle_info({:udp, _, _ip, _port, packet}, state) do
    IO.inspect "message recieved for udp tracker #{packet}"
    {:noreply, state}
  end

end

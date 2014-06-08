defmodule Trex.UDPConnector do
  use GenServer.Behaviour

  #External API
  def new(port, handler) do
    :gen_server.start_link(__MODULE__, [port, handler], [])
  end

  def send(pid, [host, port], message) do
    :gen_server.call(pid, %{target: [host, port], message: message})
  end


  #GenServer Callbacks
  def init([port, handler]) do
    {:ok, socket} = :gen_udp.open(port, [:binary, {:active, true}])
    {:ok, %{:socket => socket, :handler => handler}}
  end

  def handle_call(%{target: [host, port], message: message}, _from, %{socket: socket} = state) do
    {:reply, :gen_udp.send(socket, host, port, message), state}
  end

  #Incoming messages from socket
  def handle_info({:udp, _, _ip, _port, packet}, %{:handler => handler} = state) do
    handler.(packet)
    {:noreply, state}
  end

end

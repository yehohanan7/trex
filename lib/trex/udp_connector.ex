defmodule Trex.UDPConnector do
  use GenServer.Behaviour

  #External API

  def new(port, handler_pid) do
    {:ok, pid} = :gen_server.start_link(__MODULE__, [port, handler_pid], [])
    {:ok, port} = :gen_server.call(pid, :get_port)
    {pid, port}
  end

  def send(pid, {host, port}, message) do
    IO.inspect "host : #{host}, port: #{port}"
    :gen_server.call(pid, %{target: {host, port}, message: message})
  end

  #GenServer Callbacks
  def init([port, handler_pid]) do
    {:ok, socket} = :gen_udp.open(port, [:binary, {:active, true}])
    {:ok, port} =  :inet.port(socket)
    {:ok, %{:socket => socket, :handler => handler_pid, :port => port}}
  end

  def handle_call(%{target: {host, port}, message: message}, _from, %{socket: socket} = state) do
    {:reply, :gen_udp.send(socket, host, port, message), state}
  end

  def handle_call(:get_port, _from, %{port: port} = state) do
    {:reply, {:ok, port}, state}
  end

  #Incoming messages from socket
  def handle_info({:udp, _, _ip, _port, packet}, %{:handler => handler_pid} = state) do
    :gen_fsm.send_event(handler_pid, packet)
    {:noreply, state}
  end

end

defmodule Trex.PeerReceiver do
  use GenServer

  @time_out 0

  def start_link(sock, ppid) do
    GenServer.start_link(__MODULE__, %{sock: sock, ppid: ppid}, [])
  end

  def init(state) do
    {:ok, state, @time_out}
  end

  def handle_info(:timeout, %{sock: sock, ppid: ppid} = state) do
    case recv(sock) do
      packet -> :gen_fsm.send_event(ppid, {:message, packet});{:noreply, state, @time_out}
      :error -> :gen_fsm.send_event(ppid, {:message, :error});{:stop, :shutdown, state}
    end
  end

  def recv(sock) do
    try do
      case do_recv(sock, 1) do
        :error             -> :error
        <<0 :: size(8)>>   -> :keepalive
        <<len :: size(8)>> -> do_recv(sock, len)
      end
    rescue
       e in _ -> IO.inspect e; :error
    end
  end

  def do_recv(sock, size) do
    case :gen_tcp.recv(sock, size) do
      {:ok, packet} -> packet
      e -> :error
    end
  end

end

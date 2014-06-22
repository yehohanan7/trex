defmodule Trex.HttpTracker do
  @behaviour :gen_fsm
  alias Trex.Url

  @time_out 0

  #External API
  def start_link(id, url, torrent) do
    {host, port} = Url.parse(url)
    :gen_fsm.start_link({:local, id}, __MODULE__, {host, port, torrent}, [])
  end

  #GenFSM Callbacks
  def init({host, port, torrent}) do
    {:ok, :initialized, %{remote_tracker: {host, port}}, @time_out}
  end

  def terminate(_reason, _statename, _state) do
    :ok
  end

  #States
  def initialized(event, state) do
    {:next_state, :connector_ready, state}
  end


  #Utils


end

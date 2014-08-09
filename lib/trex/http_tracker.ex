defmodule Trex.HttpTracker do
  @behaviour :gen_fsm
  alias Trex.HTTP.Messages
  alias Trex.Torrent
  alias Trex.Http

  @time_out 0

  @events %{:started => "started", :stopped => "stopped", :completed => "completed"}

  #External API
  def start_link(url, tpid) do
    :gen_fsm.start_link(__MODULE__, {url, tpid}, [])
  end

  #GenFSM Callbacks
  def init({url, tpid}) do
    {:ok, :getting_peers, %{url: url, tpid: tpid}, @time_out}
  end

  def terminate(_reason, _statename, _state) do
    :ok
  end

  #States
  def getting_peers(event, %{url: url, tpid: tpid} = state) do
    try do
      %{peers: peers, interval: interval} = Torrent.infohash(tpid)
      |> Messages.announce_request(url, @events[:started])
      |> Http.get([{"User-Agent", "Trex"}])
      |> Messages.parse_response

      Torrent.update_peers(tpid, {:peers, peers})
      {:next_state, :getting_peers, Dict.put(state, :peers, peers), interval * 1000}
    rescue
      e in _ -> {:stop, "error while fetching peers from #{url}", state}
    end
  end

  #Event handlers
  def handle_info(_msg, _state_name, state) do
    raise "uknown message recieved from #{state[:url]}"
  end


end

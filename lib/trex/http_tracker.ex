defmodule Trex.HttpTracker do
  @behaviour :gen_fsm
  alias Trex.HTTP.Messages
  alias Trex.Peer

  @time_out 0
  @events %{:started => "started", :stopped => "stopped", :completed => "completed"}

  #External API
  def start_link(id, url, torrent) do
    :gen_fsm.start_link({:local, id}, __MODULE__, {id, url, torrent}, [])
  end

  #Private utility methods
  defp announce(url, request) do
    try do
      %HTTPotion.Response{body: body} = HTTPotion.get(url <> request)
      body |> Messages.parse_response
    rescue
      e in HTTPotion.HTTPError -> {:stop, "could not contact the tracker", %{}}
    end
  end


  #GenFSM Callbacks
  def init({id, url, torrent}) do
    {:ok, :initialized, %{id: id, url: url, torrent: torrent}, @time_out}
  end

  def terminate(_reason, _statename, %{url: url, torrent: torrent}) do
    announce(url, Messages.announce_request(torrent[:info_hash], @events[:stopped]))
    :ok
  end

  #States
  def initialized(event, %{url: url, torrent: torrent} = state) do
    %{peers: peers, interval: interval} = announce(url, Messages.announce_request(torrent[:info_hash], @events[:started]))
    Peer.peers_found(torrent[:id], {:peers, peers})
    {:next_state, :initialized, Dict.put(state, :peers, peers), interval}
  end

end

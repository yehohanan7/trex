defmodule Trex.HttpTracker do
  @behaviour :gen_fsm
  alias Trex.Url
  alias Trex.HTTP.Messages
  alias Trex.Peer

  @time_out 0

  #External API
  def start_link(id, url, torrent) do
    :gen_fsm.start_link({:local, id}, __MODULE__, {url, torrent}, [])
  end


  #GenFSM Callbacks
  def init({url, torrent}) do
    {:ok, :initialized, %{url: url, torrent: torrent}, @time_out}
  end

  def terminate(_reason, _statename, _state) do
    :ok
  end

  #States
  def initialized(event, %{url: url, torrent: torrent} = state) do
    try do
      response = HTTPotion.get url <> Messages.announce_request(torrent[:info_hash])
      %HTTPotion.Response{body: body} = response
      {:peers, peers} = Messages.parse_response body
      {:next_state, :announced, Dict.put(state, :peers, peers), @time_out}
    rescue
      e in HTTPotion.HTTPError -> {:stop, "could not contact the tracker", %{}}
    end
  end

  def announced(_event, %{torrent: torrent, peers: peers} = state) do
    Peer.peers_found(torrent[:id], {:peers, peers})
    {:next_state, :announced, state}
  end

end

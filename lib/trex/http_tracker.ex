defmodule Trex.HttpTracker do
  @behaviour :gen_fsm
  alias Trex.HTTP.Messages
  alias Trex.Torrent
  import IEx

  @time_out 0
  @retry_interval 10000

  @events %{:started => "started", :stopped => "stopped", :completed => "completed"}

  #External API
  def start_link(info_hash, url, torrent_pid) do
    :gen_fsm.start_link(__MODULE__, {info_hash, url, torrent_pid}, [])
  end

  #GenFSM Callbacks
  def init({info_hash, url, torrent_pid}) do
    {:ok, :initialized, %{info_hash: info_hash, url: url, torrent_pid: torrent_pid}, @time_out}
  end

  def terminate(_reason, _statename, state) do
    #announce(url, torrent[:info_hash], @events[:stopped]);
    :ok
  end

  #States
  def initialized(event, %{info_hash: info_hash, url: url} = state) do
    %{peers: peers, interval: interval} = announce(url, info_hash, @events[:started])
    Torrent.peers_found({:peers, peers})
    {:next_state, :initialized, Dict.put(state, :peers, peers), interval * 1000}
  end

  #Event handlers
  def handle_info(msg, state_name, state) do
    raise "uknown message recieved from #{state[:url]}"
  end

  #Private utility methods
  defp announce(url, info_hash, event) do
    request = Messages.announce_request_params(info_hash, event)
    %HTTPotion.Response{body: body} = HTTPotion.get(url <> request)
    Messages.parse_response body
  end


end

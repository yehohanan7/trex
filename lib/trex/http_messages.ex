defmodule Trex.HTTP.Messages do
  alias Trex.BEncoding
  alias Trex.Config, as: Config

  def parse_response(data) do
    %{"peers" => peers, "interval" => interval} = data |> String.strip |> :binary.bin_to_list |> BEncoding.decode
    %{
      :peers    => peers |> Enum.map(fn (%{"ip" => ip, "port" => port}) -> {ip, port} end),
      :interval => interval
    }
  end

  def announce_request(info_hash, url, event) do
    params = %{"info_hash" => info_hash |> Hex.decode |> URI.encode,
               "peer_id"   => Config.peer_id,
               "port"      => "7887",
               "uploaded"  => "0",
               "downloaded"=> "0",
               "left"      => "0",
               "event"     => event,
               "numwant"   => "200",
               "no_peer_id"=> "1"}
              |> 
              Enum.reduce(<<>>, fn ({key, value}, acc) -> acc <> "#{key}=#{value}&" end)
   url <> "?" <> params
  end

end

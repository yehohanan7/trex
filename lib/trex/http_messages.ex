defmodule Trex.HTTP.Messages do
  alias Trex.BEncoding

  @default_interval 200

  defp parse_peers(data) when is_binary(data), do: []
  defp parse_peers(data), do: data


  def parse_response(data) do
    %{"peers" => peers, "interval" => interval} = data |> String.strip |> :binary.bin_to_list |> BEncoding.decode
    %{
      :peers    => peers |> parse_peers |> Enum.map(fn(%{"ip" => ip, "port" => port}) -> {ip, port} end),
      :interval => interval
    }
  end

  def announce_request(url, info_hash, event) do
    params = %{"info_hash" => info_hash |> Hex.decode |> URI.encode,
               "peer_id"   => "ABCDEFGHIJKLMNOPQRST",
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

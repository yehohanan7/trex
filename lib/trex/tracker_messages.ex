defmodule Trex.Tracker.Messages do

  @actions %{:connect   => 0,
             :announce  => 1,
             :scrape    => 2,
             :error     => 3}

  @events %{:none      => 0,
            :completed => 1,
            :started   => 2,
            :stopped   => 3}

  defp to_binary({value, :full}) when is_binary(value) do
    <<value::binary>>
  end

  defp to_binary({value, bytes}) when is_binary(value) do
    <<value::[size(bytes), binary]>>
  end

  defp to_binary({value, bytes}) do
    bits = bytes * 8
    <<value::[size(bits)]>>
  end
  
  defp to_binary(data) when is_list(data) do
    Enum.reduce(Keyword.values(data), <<>>, fn (x, acc) -> acc <> to_binary(x) end)
  end

  def connect_request(transaction_id) do
    [prefix:         {4497486125440, 8},
     action:         {@actions[:connect], 4},
     transaction_id: {transaction_id, :full}]
    |> to_binary
  end

  def announce_request(transaction_id, connection_id, info_hash, port) do
    [connection_id:   {connection_id, 8},
     action:          {@actions[:announce], 4},
     transaction_id:  {transaction_id, 4},
     info_hash:       {info_hash, 20},
     peer_id:         {1, 20},
     downloaded:      {0, 8},
     left:            {0, 8},
     uploaded:        {0, 8},
     event:           {@events[:started], 4},
     ip:              {0, 4},
     key:             {0, 4},
     num_want:        {50, 4},
     port:            {port, 2}]
    |> to_binary       
  end
  
  def parse_response(packet, transaction_id) do

    case packet do
      <<0::32, transaction_id::[size(4), binary], connection_id::binary>> -> 
        {:connection_id, connection_id}

      <<1::32, transaction_id::[size(4), binary], interval::32, leechers::32, seeder::32, rest::binary>> ->
        IO.inspect "interval : #{interval}"
        IO.inspect "seeder : #{seeder}"
        IO.inspect(decode_peer(rest, []))

      <<3::32, transaction_id::[size(4), binary], rest::binary>> ->
        IO.inspect "error packet recieved : #{rest}"

      _ -> IO.inspect "unknown response";:unknown_response
        
    end

  end


  def decode_peer(<<a::8, b::8, c::8, d::8, port::16, rest::binary>>, acc) do
    decode_peer(rest, [{{a,b,c,d}, port} | acc])
  end

  def decode_peer(<<>>, acc), do: acc

end

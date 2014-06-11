defmodule Trex.Tracker.Messages do


  @actions %{:connect   => 0,
             :announce  => 1,
             :scrape    => 2,
             :error     => 3}

  @events %{:none      => 0,
            :completed => 1,
            :started   => 2,
            :stopped   => 3}


  def connect_request(transaction_id) do
    <<4497486125440::64,@actions[:connect]::32, transaction_id::binary>>
  end

  def announce_request(transaction_id, connection_id, torrent) do
    peer_id = 1; ip = key = uploaded = downloaded = left = 0; num_want = 50; port = 9998
    <<connection_id::[size(8), binary], @actions[:announce]::32, transaction_id::[size(4), binary], torrent[:info_hash]::[size(20), binary], 
    peer_id::160,downloaded::64, left::64, uploaded::64, @events[:started]::32, ip::32, key::32, num_want::32, 9998::16>>
  end
  
  def parse_response(packet, transaction_id) do
    
    IO.inspect packet

    case packet do
      <<0::32, transaction_id::[size(4), binary], connection_id::binary>> -> 
        {connection_id: connection_id}

      <<1::32, transaction_id::[size(4), binary], interval::32, leechers::32, seeder::32, rest::binary>> ->
        decode_peer(rest)
      _ ->
        :error
    end

  end


  def decode_peer(<<a::8, b::8, c::8, d::8, port::16>>) do
    {{a,b,c,d}, port}
  end



end

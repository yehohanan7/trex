defmodule TestPeer do
    alias Trex.Peer

    def test do
      Peer.start({"24.231.67.232", 24650}, self())
    end

end

#"handshake completed for 24.231.67.232:24650  hash: 299c8ab171f489ad9c0c481da0191f1d6970f98c"
#"handshake completed for 77.175.108.119:13123  hash: 299c8ab171f489ad9c0c481da0191f1d6970f98c"
#"handshake completed for 89.159.202.96:44425  hash: 299c8ab171f489ad9c0c481da0191f1d6970f98c"
#"handshake completed for 70.68.122.205:28049  hash: 299c8ab171f489ad9c0c481da0191f1d6970f98c"
#"handshake completed for 178.36.20.192:59807  hash: 299c8ab171f489ad9c0c481da0191f1d6970f98c"
#"handshake completed for 176.127.229.229:20074  hash: 299c8ab171f489ad9c0c481da0191f1d6970f98c"
#"handshake completed for 85.167.101.249:28077  hash: 299c8ab171f489ad9c0c481da0191f1d6970f98c"
#"handshake completed for 72.185.185.141:54312  hash: 299c8ab171f489ad9c0c481da0191f1d6970f98c"
#"handshake completed for 82.75.117.180:1111  hash: 299c8ab171f489ad9c0c481da0191f1d6970f98c"
#"handshake completed for 193.92.60.224:36496  hash: 299c8ab171f489ad9c0c481da0191f1d6970f98c"
#"handshake completed for 79.177.122.187:61661  hash: 299c8ab171f489ad9c0c481da0191f1d6970f98c"
#"handshake completed for 207.204.75.159:16684  hash: 299c8ab171f489ad9c0c481da0191f1d6970f98c"
#"handshake completed for 122.164.27.216:21042  hash: 299c8ab171f489ad9c0c481da0191f1d6970f98c"
#"handshake completed for 24.58.230.110:19880  hash: 299c8ab171f489ad9c0c481da0191f1d6970f98c"
#"handshake completed for 14.47.4.183:46569  hash: 299c8ab171f489ad9c0c481da0191f1d6970f98c"
#"handshake completed for 69.254.120.151:42161  hash: 299c8ab171f489ad9c0c481da0191f1d6970f98c"
#"handshake completed for 46.59.34.250:24716  hash: 299c8ab171f489ad9c0c481da0191f1d6970f98c"
#"handshake completed for 84.229.157.100:26043  hash: 299c8ab171f489ad9c0c481da0191f1d6970f98c"
#"handshake completed for 190.166.143.149:22725  hash: 299c8ab171f489ad9c0c481da0191f1d6970f98c"
#"handshake completed for 76.170.212.194:42725  hash: 299c8ab171f489ad9c0c481da0191f1d6970f98c"

alias Trex.Peer
Peer.start({"89.159.202.96", 44425}, self())
:gen_tcp.send(sock, <<0,0,13,6,1,5>>)

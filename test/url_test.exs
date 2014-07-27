defmodule UrlTest do
  use ExUnit.Case
  import Trex.Url

  test "parse http url" do
    url = "http://localhost:8080/announce"
    assert (url == parse_url(url))
  end

  test "parse udp url" do
    assert ({'localhost', 8080} == parse_url("udp://localhost:8080/announce"))
  end
  
end

defmodule Trex.Url do

  defp domain_port(url) do
    [host, _path] = String.split(url, "/")
    [domain, port] = cond do
      String.contains?(host, ":") -> String.split(host, ":")
      true -> [host, "80"]
    end
    {to_char_list(domain), binary_to_integer(port)}
  end

  def parse(<<"udp://", path::binary>>) do
    domain_port(path)
  end

  def parse(<<"http://", path::binary>>) do
    domain_port(path)
  end

end

defmodule BEncoding do

  def decode(data) do
    decode_binary(data)
  end

  def decode_binary(<<?l, rest::binary>>) do
    decode_list(rest, [])
  end

  def decode_binary(<<?i, rest::binary>>) do
    decode_integer(rest, <<>>)
  end

  def decode_binary(<<?d, rest::binary>>) do

  end


  def decode_list(<<?e, rest::binary>>, acc) do
    {{:list, Enum.reverse(acc)}, rest}
  end

  def decode_list(data, acc) do
    {result, rest} = decode_binary(data)
    decode_list(rest, [result | acc])
  end

  def decode_integer(<<?e, rest::binary>>, acc) do
    {acc |> String.reverse |> bitstring_to_integer, rest}
  end

  def decode_integer(<<x, rest::binary>>, acc) do
    decode_integer(rest, <<x>> <> acc)
  end

  defp bitstring_to_integer (bitstring) do
    bitstring |> bitstring_to_list |> Enum.join |> binary_to_integer
  end

end

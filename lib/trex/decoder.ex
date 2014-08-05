defmodule Trex.Decoder do
  @moduledoc """
  Decodes an B-Encoded torrent file.
  """
  defmacro __using__(_)  do
    quote do

        defp list_to_integer(x) do
          x |> IO.chardata_to_string |> String.to_integer
        end

        def decode(data) do
          elem(decode_data(data), 0)
        end

        def decode_data([?l | rest]) do
          decode_list(rest, [])
        end

        def decode_data([?i | rest]) do
          decode_integer(rest, [])
        end

        def decode_data([?d | rest]) do
          decode_dict(rest, %{})
        end

        def decode_data(data) do
          decode_string(data, [])
        end

        def decode_string([?: | rest], acc) do
          int = acc |> Enum.reverse |> list_to_integer
          {str, rest} = Enum.split(rest, int)
          {IO.iodata_to_binary(str), rest}
        end

        def decode_string([x | rest], acc) do
          decode_string(rest, [x | acc])
        end

        def decode_dict([?e | rest], acc) do
          {acc, rest}
        end

        def decode_dict(data, acc) do
          {key, rest} = decode_data(data)
          {value, rest} = decode_data(rest)
          decode_dict(rest, Dict.put(acc, key, value))
        end

        def decode_list([?e | rest], acc) do
          {Enum.reverse(acc), rest}
        end

        def decode_list(data, acc) do
          {result, rest} = decode_data(data)
          decode_list(rest, [result | acc])
        end

        def decode_integer([?e | rest], acc) do
          {acc |> Enum.reverse |> list_to_integer, rest}
        end

        def decode_integer([x | rest], acc) do
          decode_integer(rest, [x | acc])
        end
    end
  end
end

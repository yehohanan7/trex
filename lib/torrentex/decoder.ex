defmodule Torrentex.Decoder do
  @moduledoc """
  Decodes an B-Encoded torrent file.
  """
  defmacro __using__(_)  do
    quote do
        def decode(data) do
          decode_data(data)
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
          {iodata_to_binary(str), rest}
        end

        def decode_string([x | rest], acc) do
          decode_string(rest, [x | acc])
        end

        def decode_dict([?e | rest], acc) do
          {{:dict, acc}, rest}
        end

        def decode_dict(data, acc) do
          {key, rest} = decode_data(data)
          {value, rest} = decode_data(rest)
          decode_dict(rest, Dict.put(acc, key, value))
        end

        def decode_list([?e | rest], acc) do
          {{:list, Enum.reverse(acc)}, rest}
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

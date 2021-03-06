defmodule Trex.Encoder do

  defmacro __using__(_)  do
    
    quote do
      def encode(value) when is_number(value) do
        "i#{value}e"
      end

      def encode(value) when is_binary(value) do
        "#{byte_size(value)}:#{value}"
      end

      def encode([_ | _] = xs) do
        "l" <> Enum.reduce(xs, <<>>, fn (x, acc) -> acc <> encode(x) end) <> "e"
      end

      def process_entry({key, value}, acc) do
        acc <> encode(key) <> encode(value)
      end

      def encode(%{} = dict) do
        "d" <> Enum.reduce(dict, <<>>, &process_entry/2) <> "e"
      end
    end

  end

end

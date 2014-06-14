defmodule Trex.Lambda do
  
  def string_to_atom x do
    x |> String.to_char_list |> List.to_atom
  end
  
end

defmodule Macros do

  def macro do
    test = fn -> IO.inspect "inside test..." end
    test.()
  end

end

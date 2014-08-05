defmodule TestBEncoding do
    use ExUnit.Case
    import Trex.BEncoding

    test "encode string" do
      assert("4:test" == encode("test"))
    end

    test "encode integer" do
      assert("i5e" == encode(5))
    end

    test "encode list" do 
      assert("l4:testi5ee" = encode(["test", 5]))
    end

    test "encode dict" do 
      assert("d4:test5:valuee" = encode(%{"test" => "value"}))
    end

    test "decode string" do 
      assert("test" == decode('4:test'))
    end

    test "decode integer" do
      assert(5 == decode('i5e'))
    end

    test "decode list" do 
      assert(["test", "value"] == decode('l4:test5:valuee'))
    end

    test "decode dict" do
      assert(%{"test" => "value"} == decode('d4:test5:valuee'))
    end

    
end

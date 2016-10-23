defmodule Tavern.QueueTest do
    use ExUnit.Case

    setup do
        {:ok, queue} = Tavern.Queue.start_link  
        {:ok, queue: queue}   # returns queue dict, allows use across tests
    end

    # uses the bucket pid created in setup
    test "store messages", %{queue: queue} do    
        assert Tavern.Queue.get(queue) == {:no_messages}

        Tavern.Queue.put(queue, {"hello", self()})
        Tavern.Queue.put(queue, {"world", self()})

        assert Tavern.Queue.get(queue) == {:ok, {"hello", self()}}
        assert Tavern.Queue.get(queue) == {:ok, {"world", self()}}
        assert Tavern.Queue.get(queue) == {:no_messages}
    end
end
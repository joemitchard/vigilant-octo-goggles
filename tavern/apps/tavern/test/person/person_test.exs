defmodule Tavern.PersonTest do
    use ExUnit.Case

    setup do
        {:ok, queue} = Tavern.Queue.start_link
        {:ok, person} = Tavern.Person.start_link :p1, queue
        {:ok, [person: person, queue: queue]}
    end

    # uses the bucket pid created in setup
    test "get messages", %{person: person, queue: queue} do    

        Tavern.Queue.put(queue, {"hello", self()})
        Tavern.Queue.put(queue, {"world", self()})

        assert Tavern.Person.get_messages(person) === :ok

    end
end
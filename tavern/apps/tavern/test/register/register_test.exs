defmodule Tavern.RegisterTest do
    use ExUnit.Case, async: true

    setup context do
        # pass the test context as the name
        {:ok, register} = Tavern.Register.start_link context.test
        {:ok, register: register}
    end

    test "spawn queues", %{register: register} do
        assert Tavern.Register.lookup(register, "test") == :error

        Tavern.Register.create(register, "test")

        assert {:ok, queue} = Tavern.Register.lookup(register, "test")

        Tavern.Queue.put(queue, "hello")
        Tavern.Queue.put(queue, "world")

        assert Tavern.Queue.get(queue) == {:ok, "hello"}
        assert Tavern.Queue.get(queue) == {:ok, "world"}
        assert Tavern.Queue.get(queue) == {:no_messages}

    end

    test "removes queues on exit", %{register: register} do
        Tavern.Register.create(register, "test")
        {:ok, queue} = Tavern.Register.lookup(register, "test")
        Agent.stop(queue)
        assert Tavern.Register.lookup(register, "test") == :error
    end
end
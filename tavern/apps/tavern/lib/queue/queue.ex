defmodule Tavern.Queue do

    @doc """
    Starts a new queue
    - passes an empty queue 
    """
    def start_link do
        Agent.start_link(fn -> [] end)
    end

    @doc """
    Gets a message from the queue
    """
    def get(queue) do
        Agent.get_and_update(queue, fn messages ->
            {(pop messages), (safe_tail messages)}
        end)
    end

    @doc """
    Put a messgae onto the queue
    """
    def put(queue, msg) do
        Agent.update(queue, fn messages ->  [msg] ++ messages end)        
    end

    defp pop([]), do: :no_messages
    defp pop([head | _]) do
        head
    end

    defp safe_tail([]), do: []
    defp safe_tail([_|rest]) do
        rest
    end
end

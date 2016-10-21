defmodule Queue do

    @doc """
    Starts a new queue
    - passes an empty queue 
    """
    def start_link do
        # Agent.start_link(fn -> loop([]) end)
        spawn fn -> loop([]) end
    end

    @doc """
    Gets a message from the queue
    """
    def get(queue) do
        send(queue, {:get, self()})
        receive do x -> x end
    end

    @doc """
    Put a messgae onto the queue
    """
    def put(queue, msg) do
        send(queue, {:put, msg, self()})
        receive do
            x -> x
        end
        
    end


    # queue implementation
    defp loop(messages) do
        receive do
            {:get, from} ->
                send(from, {:ok, hd messages})
                loop(tl messages)
            {:put, msg, from} ->
                send(from, {:ok})
                loop(messages ++ [msg])
        end
    end
end
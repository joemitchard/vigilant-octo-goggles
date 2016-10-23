defmodule Tavern.Person do
    use GenServer

    # Client Api

    @doc """
    Start a new person
    `name` is the name of the person, `queue` is the queue to subscribe to
    """
    def start_link(name, queue) do
        GenServer.start_link(__MODULE__, queue, name: name)
    end

    @doc """
    Get all incoming messages held in persons `queue`
    """
    def get_messages(pid) do
        GenServer.call(pid, {:get_messages})
    end


    # Server callbacks
    def init(queue) do
        {:ok, queue}
    end

    def handle_call({:get_messages}, _from, queue) do
        read_from_queue queue
        {:reply, :ok, queue}
    end

    defp read_from_queue(queue) do
        case Tavern.Queue.get(queue) do
            {:no_messages}      -> 
                IO.puts("No messages")
            {:ok, msg}          -> 
                IO.puts("received: #{msg}")
                read_from_queue(queue)
        end
    end
end
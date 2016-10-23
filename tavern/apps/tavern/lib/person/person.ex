defmodule Tavern.Person do
    require Logger
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
    Currently only prints them, need to send them to server
    """
    def get_messages(pid) do
        GenServer.call(pid, {:get_messages})
    end

    @doc """
    Send a message to a given `queue` 
    """
    def send(pid, message, queue) do
        GenServer.call(pid, {:send, message, queue})
    end

    @doc """
    Returns the persons queue
    """
    def get_queue(pid) do
        GenServer.call(pid, {:get_queue})
    end

    # Server callbacks
    def init(queue) do
        {:ok, queue}
    end

    def handle_call({:get_messages}, _from, queue) do
        read_from_queue queue
        {:reply, :ok, queue}
    end

    def handle_call({:send, message, to}, _from, queue) do
        task = Task.async(fn -> Tavern.Queue.put(to, {message, self()}) end)

        Logger.debug("#{inspect self()}: Sending message to: #{inspect to}\r\n")

        Task.await(task)

        Logger.debug("{inspect self()}: Sent\r\n")

        {:reply, :ok, queue}
    end

    def handle_call({:get_queue}, _from, queue) do
        {:reply, queue, queue}
    end

    # This needs to eventually send each message to the server for it to handle
    defp read_from_queue(queue) do
        case Tavern.Queue.get(queue) do
            {:no_messages}      -> 
                IO.puts("No messages")
            {:ok, {msg, from}} -> 
                IO.puts("#{inspect self()} received: #{msg} from #{inspect from}")
                read_from_queue(queue)
        end
    end
end
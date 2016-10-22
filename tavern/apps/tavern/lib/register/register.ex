defmodule Tavern.Register do
    use GenServer

    # Client Api
    @doc """
    Start a new register
    """
    def start_link(name) do
        GenServer.start_link(__MODULE__, [], name: name) # bind the name passed from sup
    end

    @doc """
    Find a queue
    """
    def lookup(server, name) do
        GenServer.call(server, {:lookup, name})
    end

    @doc """
    Create a new queue and add it to the queue register
    """
    def create(server, name) do
        GenServer.call(server, {:create, name})
    end

    @doc """
    Stops the registry.
    """
    def stop(server) do
        GenServer.stop(server)
    end

    # Gen server callbacks
    def init(_args) do
        names = %{}
        refs  = %{}
        {:ok, {names, refs}}
    end
    
    def handle_call({:lookup, name}, _from, {names, _} = state) do
        {:reply, Map.fetch(names, name), state}
    end
    
    def handle_call({:create, name}, _from, {names, refs} = state) do
        if Map.has_key?(names, name) do
            {:reply, :already_exists, state}
        else
            {:ok, queue} = Tavern.Queue.Supervisor.start_queue
            ref = Process.monitor(queue)
            refs = Map.put(refs, ref, name)
            names = Map.put(names, name, queue)
            {:reply, :ok, {names, refs}}        
        end
    end

    def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
        {name, refs} = Map.pop(refs, ref)
        names = Map.delete(names, name)
        {:noreply, {names, refs}}
    end

    def handle_info(_msg, state) do
        {:noreply, state}
    end
end
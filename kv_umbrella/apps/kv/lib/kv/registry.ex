defmodule KV.Registry do
    use GenServer

    # Client Api
    @doc """
    Start the registry with given name
    """
    def start_link(name) do
        # pass the name to the init function
        GenServer.start_link(__MODULE__, name, name: name)
    end

    @doc """
    looks up the bucket pid for name stored in server
    returns {:ok, pid} if the bucket exists, or :error
    """
    def lookup(server, name) when is_atom(server) do
        case :ets.lookup(server, name) do
            [{^name, pid}]  -> {:ok, pid}
            []              -> :error
        end
    end

    @doc """
    Ensure that a bucket is associated with a given name in server
    """
    def create(server, name) do
        GenServer.call(server, {:create, name})
    end

    @doc """
    Stops the registry
    """
    def stop(server) do
        GenServer.stop(server)
    end

    # callbacks
    def init(table) do
        names = :ets.new(table, [:named_table, read_concurrency: true])
        refs  = %{}
        {:ok, {names, refs}}
    end

    def handle_call({:create, name}, _from, {names, refs}) do
        case lookup(names, name) do
            {:ok, pid} ->
                {:reply, pid, {names, refs}}
            :error ->
                {:ok, pid} = KV.Bucket.Supervisor.start_bucket
                ref = Process.monitor(pid)
                refs = Map.put(refs, ref, name)
                :ets.insert(names, {name, pid})
                {:reply, pid, {names, refs}}
        end
    end

    def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
        {name, refs} = Map.pop(refs, ref)
        :ets.delete(names, name)
        {:noreply, {names, refs}}
    end

    def handle_info(_msg, state) do
        {:noreply, state}
    end
end
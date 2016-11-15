defmodule KV.Registry do
    use GenServer

    # Client Api
    @doc """
    Start the registry with given name
    """
    def start_link(name, event_manager, ets) do
        # pass the name to the init function
        GenServer.start_link(__MODULE__, {ets, event_manager}, name: name)
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
    def init({ets_table, event_manager}) do
        #refs  = %{}

        refs = :ets.foldl(fn {name, pid}, acc ->
            Map.put(acc, Process.monitor(pid), name)
        end, Map.new, ets_table)

        {:ok, %{names: ets_table, refs: refs, event_man: event_manager}}
    end

    def handle_call({:create, name}, _from, state) do
        case lookup(state.names, name) do
            {:ok, pid} ->
                {:reply, pid, state}
            :error ->
                {:ok, pid} = KV.Bucket.Supervisor.start_bucket
                ref = Process.monitor(pid)
                refs = Map.put(state.refs, ref, name)
                :ets.insert(state.names, {name, pid})
                GenEvent.sync_notify(state.event_man, {:create, name, pid})
                {:reply, pid, %{state | refs: refs}}
        end
    end

    def handle_info({:DOWN, ref, :process, pid, _reason}, state) do
        {name, refs} = Map.pop(state.refs, ref)
        :ets.delete(state.names, name)
        GenEvent.sync_notify(state.event_man, {:exit, name, pid})
        {:noreply, %{state | refs: refs}}
    end

    def handle_info(_msg, state) do
        {:noreply, state}
    end
end
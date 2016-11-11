defmodule KV.Supervisor do
    use Supervisor

    def start_link do
        Supervisor.start_link(__MODULE__, :ok)
    end

    @manager_name KV.EventManager
    @registry_name KV.Registry
    @ets_registry_name KV.Registry

    def init(:ok) do
        ets = :ets.new(@ets_registry_name, [:set, :public, :named_table, {:read_concurrency, true}])

        children = [
            worker(GenEvent, [[name: @manager_name]]),
            worker(KV.Registry, [@registry_name, @manager_name, ets]),
            supervisor(KV.Bucket.Supervisor, []),
            supervisor(Task.Supervisor, [[name: KV.RouterTasks]])
        ]

        supervise(children, strategy: :one_for_one)
    end
end
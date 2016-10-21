defmodule Tavern.Queue.Supervisor do
    use Supervisor

    # A simple module attibute that stores the module name
    @name Tavern.Queue.Supervisor

    def start_link do
        Supervisor.start_link(__MODULE__, :ok, name: @name)
    end

    def start_queue do
        Supervisor.start_child(@name, [])
    end

    def init(:ok) do
        children = [
            worker(Tavern.Queue, [], restart: :temporary)
        ]

        supervise(children, strategy: :simple_one_for_one)
    end
end
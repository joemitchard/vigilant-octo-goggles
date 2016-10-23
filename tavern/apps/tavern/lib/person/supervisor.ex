defmodule Tavern.Person.Supervisor do
    use Supervisor

    # A simple module attibute that stores the module name
    @name Tavern.Person.Supervisor

    def start_link do
        Supervisor.start_link(__MODULE__, :ok, name: @name)
    end

    def start_person(name, queue) do
        Supervisor.start_child(@name, [name, queue])
    end

    def init(:ok) do
        children = [
            worker(Tavern.Person, [], restart: :temporary)
        ]

        supervise(children, strategy: :simple_one_for_one)
    end
end
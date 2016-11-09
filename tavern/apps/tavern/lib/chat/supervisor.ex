defmodule Tavern.Chat.Supervisor do
    use Supervisor

    # A simple module attibute that stores the module name
    @name Tavern.Chat.Supervisor

    def start_link do
        Supervisor.start_link(__MODULE__, :ok, name: @name)
    end

    def start_chat(userid_1, userid_2) do
        Supervisor.start_child(@name, [userid_1, userid_2])
    end

    def init(:ok) do
        children = [
            worker(Tavern.Chat, [], restart: :temporary)
        ]

        supervise(children, strategy: :simple_one_for_one)
    end
end
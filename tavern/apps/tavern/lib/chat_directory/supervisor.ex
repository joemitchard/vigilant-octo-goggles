defmodule Tavern.ChatDirectory.Supervisor do
    use Supervisor

    def start_link do
        Supervisor.start_link(__MODULE__, :ok)
    end

    def init(:ok) do
        children = [
            worker(Tavern.ChatDirectory, [Tavern.ChatDirectory]),
            supervisor(Tavern.Chat.Supervisor, [])           
        ]

        supervise(children, strategy: :one_for_one)
    end
end
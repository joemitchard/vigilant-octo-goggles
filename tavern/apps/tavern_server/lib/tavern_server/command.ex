defmodule TavernServer.Command do
    @doc """
    Parses the given `line` into a command and runs it on Tavern
    """
    def parse(line) do
        case String.split(line) do
            ["CREATE", user1, user2]    -> {:ok, {:create, user1, user2}}
            __                          -> {:error, :unknown_command}
        end
    end

    def run({:create, user1, user2}) do
        Tavern.Chat.start_link({user1, user2})
        {:ok, "OK\r\n"}
    end
end
defmodule Tavern.ChatDirectory do
    use GenServer

    @doc """
    Start the Chat Directory with a given name
    """
    def start_link(name) do
        GenServer.start_link(__MODULE__, name, name: name)
    end

    @doc """
    looks up the chat pid for name stored in server
    returns {:ok, pid} if the chat exists, or :error
    """
    def lookup(server, chat_name) when is_atom(server) do
        case :ets.lookup(server, chat_name) do
            [{^chat_name, pid}] -> {:ok, pid}
            []                  -> :error
        end
    end

    @doc """
    start new Chat with given chat name
    """
    def create_chat(server, chat_name, userid_1, userid_2) do
        GenServer.call(server, {:create, chat_name, userid_1, userid_2})
    end

    @doc """
    Stops the Chat Directory
    """
    def stop(server) do
        GenServer.stop(server)
    end


    # callbacks

    def init(dir_name) do
        chats = :ets.new(dir_name, [:named_table, read_concurrency: true])
        refs  = %{}
        {:ok, {chats, refs}}
    end

    def handle_call({:create, chat_name, userid_1, userid_2}, _from, {chats, refs}) do
        case lookup(chats, chat_name) do
            {:ok, pid} ->
                {:reply, pid, {chats, refs}}
            :error ->
                {:ok, pid} = Tavern.Chat.Supervisor.start_chat(userid_1, userid_2)
                ref = Process.monitor(pid)
                refs = Map.put(refs, ref, chat_name)
                :ets.insert(chats, {chat_name, pid})
                {:reply, pid, {chats, refs}}
        end
    end

    def handle_info({:DOWN, ref, :process, _pid, _reason}, {chats, refs}) do
        {chat_name, refs} = Map.pop(refs, ref)
        :ets.delete(chats, chat_name)
        {:noreply, {chats, refs}}
    end

    def handle_info(_msg, state) do
        {:noreply, state}
    end
end
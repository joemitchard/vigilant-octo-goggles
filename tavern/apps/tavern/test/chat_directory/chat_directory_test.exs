defmodule Tavern.ChatDirectoryTest do
    use ExUnit.Case, async: true

    setup context do
        {:ok, _} = Tavern.ChatDirectory.start_link(context.test)
        {:ok, directory: context.test}
    end

    test "spawns chats", %{directory: directory} do
        assert Tavern.ChatDirectory.lookup(directory, "new_chat") == :error

        Tavern.ChatDirectory.create_chat(directory, "new_chat", "user_1", "user_2")
        assert {:ok, chat_pid} = Tavern.ChatDirectory.lookup(directory, "new_chat")

        Tavern.Chat.send_msg(chat_pid, "a msg", "user_2")
        assert Tavern.Chat.get_msg(chat_pid, "user_2") == {:ok, "a msg"}
    end
end
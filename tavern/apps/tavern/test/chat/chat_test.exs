defmodule Tavern.ChatTest do
    use ExUnit.Case, async: true

    setup _context do
        user_1 = "lloyd@mail.com" 
        user_2 = "joe@mail.com"

        {:ok, chat} = Tavern.Chat.start_link(user_1, user_2)
        refs = %{chat: chat, user1: user_1, user2: user_2}
        {:ok, refs: refs}
    end

    test "creates chat with 2 inboxes", %{refs: refs} do
        assert Process.alive?(refs[:chat]) === true

        inbox_1 = 
            with {:ok, name} <- Tavern.Chat.lookup_inbox(refs[:chat], refs[:user1]),
                 {:ok, pid1} <- Tavern.Register.lookup(Tavern.Register, name),
                 do: pid1

        assert Process.alive?(inbox_1) === true

        inbox_2 = 
            with {:ok, name2} <- Tavern.Chat.lookup_inbox(refs[:chat], refs[:user2]),
                 {:ok, pid2} <- Tavern.Register.lookup(Tavern.Register, name2),
                 do: pid2         

        
        assert Process.alive?(inbox_2) === true 
    end

    test "can send message to inbox", %{refs: refs} do
        assert Tavern.Chat.send_msg(refs[:chat], "msg 1", refs[:user1]) === {:ok}
        assert Tavern.Chat.send_msg(refs[:chat], "msg 2", refs[:user2]) === {:ok}

        assert {:ok, "msg 1"} == 
            with {:ok, name} <- Tavern.Chat.lookup_inbox(refs[:chat], refs[:user1]),
                 {:ok, pid1} <- Tavern.Register.lookup(Tavern.Register, name),
                 do: Tavern.Queue.get(pid1)


        assert {:ok, "msg 2"} == 
            with {:ok, name2} <- Tavern.Chat.lookup_inbox(refs[:chat], refs[:user2]),
                 {:ok, pid2} <- Tavern.Register.lookup(Tavern.Register, name2),
                 do: Tavern.Queue.get(pid2)

    end

    test "can send and receive messages", %{refs: refs} do
        assert Tavern.Chat.send_msg(refs[:chat], "msg 1", refs[:user1]) === {:ok}
        assert Tavern.Chat.get_msg(refs[:chat], refs[:user1]) === {:ok, "msg 1"}

        assert Tavern.Chat.send_msg(refs[:chat], "msg 2", refs[:user2]) === {:ok}
        assert Tavern.Chat.get_msg(refs[:chat], refs[:user2]) === {:ok, "msg 2"}
    end

    test "new chat has no messages", %{refs: refs} do
        assert Tavern.Chat.get_msg(refs[:chat], refs[:user1]) === {:no_messages}

        assert Tavern.Chat.get_msg(refs[:chat], refs[:user2]) === {:no_messages}
    end
end
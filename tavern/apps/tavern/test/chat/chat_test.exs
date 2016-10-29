defmodule Tavern.ChatTest do
    use ExUnit.Case, async: true

    setup _context do
        user_1 = "lloyd@mail.com" 
        user_2 = "joe@mail.com"

        {:ok, chat} = Tavern.Chat.start_link({user_1, user_2})
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
    end
end
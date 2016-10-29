defmodule Tavern.Chat do
   use GenServer

   def start_link({userid_1, userid_2}) do 
       GenServer.start_link(__MODULE__, {userid_1, userid_2})  # userid = unique user identifier, ie: joe@mail.com 
   end
   
   def stop(server) do
       GenServer.stop(server)
   end

   def lookup_inbox(server, user) do
       GenServer.call(server, {:lookup_inbox, user})
   end


   # Callbacks

   def init({userid_1, userid_2}) do
       inbox_1 = userid_2 <> "|" <> userid_1
       inbox_2 = userid_1 <> "|" <> userid_2

       Tavern.Register.create(Tavern.Register, inbox_1)
       Tavern.Register.create(Tavern.Register, inbox_2)

       users = %{userid_1 => inbox_1, userid_2: inbox_2}

       {:ok, {users}}
   end

   def handle_call({:lookup_inbox, user}, _from, {users} = state) do
       case Map.has_key?(users, user) do
           true -> {:reply, Map.fetch(users, user), state}
           _ -> {:reply, :not_found, state} 
       end
   end

end

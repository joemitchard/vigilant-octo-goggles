defmodule Tavern.Chat do
   use GenServer

   def start_link(userid_1, userid_2) do 
       GenServer.start_link(__MODULE__, {userid_1, userid_2})  # userid = unique user identifier, ie: joe@mail.com 
   end
   
   def stop(server) do
       GenServer.stop(server)
   end

   def lookup_inbox(server, user) do
       GenServer.call(server, {:lookup_inbox, user})
   end

   def send_msg(server, msg, recipient) do
       GenServer.call(server, {:send, msg, recipient})
   end

   def get_msg(server, user) do
       GenServer.call(server, {:get_msg, user})
   end


   # Callbacks

   def init({userid_1, userid_2}) do
       inbox_1 = userid_2 <> "|" <> userid_1
       inbox_2 = userid_1 <> "|" <> userid_2

       Tavern.Register.create(Tavern.Register, inbox_1)
       Tavern.Register.create(Tavern.Register, inbox_2)

       users = %{userid_1 => inbox_1, userid_2 => inbox_2}

       {:ok, {users}}
   end

   def handle_call({:lookup_inbox, user}, _from, {users} = state) do
       case Map.has_key?(users, user) do
           true -> {:reply, Map.fetch(users, user), state}
           _ -> {:reply, :not_found, state} 
       end
   end

   def handle_call({:get_msg, recipient}, _from, {users} = state) do
       result = 
            with {:ok, inbox} <- user_exists(users, recipient),
                 {:ok, pid}   <- Tavern.Register.lookup(Tavern.Register, inbox),
                 {:ok, msg}   <- Tavern.Queue.get(pid),
                 do: {:ok, msg}

       {:reply, result, state}       
   end

   def handle_call({:send, msg, recipient}, _from, {users} = state) do
       result = 
            with {:ok, inbox} <- user_exists(users, recipient),
                 {:ok, pid}   <- Tavern.Register.lookup(Tavern.Register, inbox),
                 :ok          <- Tavern.Queue.put(pid, msg),
                 do: {:ok}

       {:reply, result, state}       
   end


   defp user_exists(users, user) do
       case Map.has_key?(users, user) do
           true -> Map.fetch(users, user)
           _    -> :not_found 
       end
   end

end

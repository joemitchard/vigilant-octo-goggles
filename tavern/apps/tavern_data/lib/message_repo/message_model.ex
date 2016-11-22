defmodule TavernData.MessageModel do
    #@enforce_keys [:chat_id, :message, :from_user, :to_user, :date_sent, :seq_num]
    defstruct [
        :chat_id, 
        :message, 
        :from_user, 
        :to_user, 
        :date_sent, 
        :seq_num
    ]
    
end
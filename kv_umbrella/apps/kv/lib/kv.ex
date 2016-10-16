defmodule KV do
    use Application

    # this is the application entry point.
    def start(_type, _args) do
        KV.Supervisor.start_link
    end
end

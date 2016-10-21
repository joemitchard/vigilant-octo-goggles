defmodule Tavern do
    use Application
    # this is the application entry point.
    def start(_type, _args) do
        Tavern.Supervisor.start_link
    end

end

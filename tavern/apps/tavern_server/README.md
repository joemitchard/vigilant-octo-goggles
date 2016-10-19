# TavernServer

# This is going to handle connections to chats

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `tavern_server` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:tavern_server, "~> 0.1.0"}]
    end
    ```

  2. Ensure `tavern_server` is started before your application:

    ```elixir
    def application do
      [applications: [:tavern_server]]
    end
    ```


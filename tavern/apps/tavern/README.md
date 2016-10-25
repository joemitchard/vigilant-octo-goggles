# Tavern

# main chat app, needs to hold a registry of different chats and people in chats

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `tavern` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:tavern, "~> 0.1.0"}]
    end
    ```

  2. Ensure `tavern` is started before your application:

    ```elixir
    def application do
      [applications: [:tavern]]
    end
    ```


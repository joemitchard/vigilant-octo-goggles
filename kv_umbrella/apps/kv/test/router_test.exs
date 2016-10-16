defmodule KV.RouterTest do
    use ExUnit.Case, async: true

    @tag :distributed
    test "route requests across nodes" do
        assert KV.Router.route("hello", Kernel, :node, []) ==
            :"foo@joe-mac"
        assert KV.Router.route("world", Kernel, :node, []) ==
            :"bar@joe-mac"
    end

    test "raises on unknown entries" do
        assert_raise RuntimeError, ~r/could not find entry/, fn ->
            KV.Router.route(<<0>>, Kernel, :node, [])
        end
    end
end


# to run distributed tests, run elixir --sname foo -S mix test --only distributed
# WHEN bar is live (iex --sname bar -S mix)
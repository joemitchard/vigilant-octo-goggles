defmodule KV.RegistryTest do
    use ExUnit.Case, async: true

    defmodule Forwarder do
        use GenEvent

        def handle_event(event, state_pid) do
            send state_pid, event
            {:ok, state_pid}
        end
    end

    setup context do
        {:ok, event_manager} = GenEvent.start_link
        {:ok, _} = KV.Registry.start_link(context.test, event_manager)

        GenEvent.add_mon_handler(event_manager, Forwarder, self())
        {:ok, registry: context.test}
    end

    test "spawn buckets", %{registry: registry} do
        assert KV.Registry.lookup(registry, "shopping") == :error

        KV.Registry.create(registry, "shopping")
        assert {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

        KV.Bucket.put(bucket, "milk", 1)
        assert KV.Bucket.get(bucket, "milk") == 1
    end

    test "removes buckets on exit", %{registry: registry} do
        KV.Registry.create(registry, "shopping")
        {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

        Agent.stop(bucket)
        # do a call to ensure that the registry processed the DOWN message
        _ = KV.Registry.create(registry, "bogus")
        assert KV.Registry.lookup(registry, "shopping") == :error
    end

    test "remove bucket on crash", %{registry: registry} do
        KV.Registry.create(registry, "shopping")
        {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

        # stop the bucket with abnormal reason
        Process.exit(bucket, :shutdown)

        #wait until bucket is dead
        ref = Process.monitor(bucket)
        assert_receive {:DOWN, ^ref, _, _, _}

        # do a call to ensure that the registry processed the DOWN message
        _ = KV.Registry.create(registry, "bogus")
        assert KV.Registry.lookup(registry, "shopping") == :error
    end
end
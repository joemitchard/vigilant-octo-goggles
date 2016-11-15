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
        #reg_name = context.test
        ets = :ets.new(context.test, [:set, :public, :named_table]) # bug -> if ets name is diff from registry name is breaks!!!
        pid = start_registry(context.test, ets)

        {:ok, registry: context.test, ets: ets, pid: pid}
        #{:ok, registry: context.test, ets: ets}
    end

    defp start_registry(reg_name, ets) do
        {:ok, event_manager} = GenEvent.start_link
        {:ok, pid} = KV.Registry.start_link(reg_name, event_manager, ets)

        GenEvent.add_mon_handler(event_manager, Forwarder, self())

        pid
    end

    test "monitors existing entries", %{registry: registry, ets: ets, pid: pid} do
        
        bucket = KV.Registry.create(registry, "shopping")

        # Kill the registry. We unlink first, otherwise it will kill the test
        Process.unlink(pid)
        Process.exit(pid, :shutdown)

        # Start a new registry with the existing table and access the bucket
        start_registry(registry, ets)
        assert KV.Registry.lookup(registry, "shopping") == {:ok, bucket}

        # Once the bucket dies, we should receive notifications
        Process.exit(bucket, :shutdown)
        assert_receive {:exit, "shopping", ^bucket}
        assert KV.Registry.lookup(registry, "shopping") == :error
    end

    test "sends events on create and crash", %{registry: registry} do
        KV.Registry.create(registry, "shopping")
        {:ok, bucket} = KV.Registry.lookup(registry, "shopping")
        assert_receive {:create, "shopping", ^bucket}

        Agent.stop(bucket)
        assert_receive {:exit, "shopping", ^bucket}

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
defmodule KV.BucketTest do
    use ExUnit.Case, async: true

    setup do
        {:ok, bucket} = KV.Bucket.start_link    # this grabs the pid of the bucket
        {:ok, bucket: bucket}   # returns bucket dict, allows use across tests
    end

    # uses the bucket pid created in setup
    test "store values by key", %{bucket: bucket} do    
        {:ok, bucket2} = KV.Bucket.start_link

        assert KV.Bucket.get(bucket, "milk") == nil

        KV.Bucket.put(bucket, "milk", 3)
        KV.Bucket.put(bucket2, "milk", 4)

        assert KV.Bucket.get(bucket, "milk") == 3
        assert KV.Bucket.get(bucket2, "milk") == 4

    end

    test "delete a value if exists", %{bucket: bucket} do
        assert KV.Bucket.delete(bucket, "eggs") == nil

        KV.Bucket.put(bucket, "eggs", 2)

        assert KV.Bucket.delete(bucket, "eggs") == 2

        assert KV.Bucket.delete(bucket, "eggs") == nil

    end



    # no crazy elixir shit...
    # test "store values by key" do
    #     {:ok, bucket} = KV.Bucket.start_link
    #     assert KV.Bucket.get(bucket, "milk") == nil

    #     KV.Bucket.put(bucket, "milk", 3)
    #     assert KV.Bucket.get(bucket, "milk") == 3
    # end
end
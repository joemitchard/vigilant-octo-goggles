# KvUmbrella

**TODO: Add description**

Compile - mix compile
Run with iex -S mix

to spawn nodes:
# iex --sname {node-name} -S mix

to interface with application:
# telnet 127.0.0.1 4040

api commands:
    # CREATE bucketname
    # PUT bucketname item count
    # GET bucketname item
    # DELETE bucketname item

test distributed:
    # iex --sname bar -S mix
    # elixir --sname foo -S mix test --only distributed



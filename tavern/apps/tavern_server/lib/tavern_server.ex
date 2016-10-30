defmodule TavernServer do

    require Logger

    @doc false
    def start(_type, _args) do
        import Supervisor.Spec

        children = [
            supervisor(Task.Supervisor, [[name: TavernServer.TaskSupervisor]]),
            worker(Task, [TavernServer, :accept, [4040]]),
        ]

        opts = [strategy: :one_for_one, name: TavernServer.Supervisor]
        Supervisor.start_link(children, opts)
    end

    @doc """
    Accepts connections on given `port`
    """
    def accept(port) do
        {:ok, socket} = :gen_tcp.listen(port,
            [:binary, packet: :line, active: false, reuseaddr: true])
        
        Logger.info "Accepting connections on port #{port}"
        loop_acceptor(socket)
    end

    defp loop_acceptor(socket) do
        {:ok, client} = :gen_tcp.accept(socket)
        
        {:ok, pid} = Task.Supervisor.start_child(TavernServer.TaskSupervisor, fn ->
            serve(client) end)

        :ok = :gen_tcp.controlling_process(client, pid)

        loop_acceptor(socket)
    end

    defp serve(socket) do
        socket
            |> read_line()
            |> write_line(socket)

        serve(socket)
    end

    defp read_line(socket) do
        {:ok, data} = :gen_tcp.recv(socket, 0)
        data
    end

    defp write_line(line, socket) do
        :gen_tcp.send(socket, line)
    end



end

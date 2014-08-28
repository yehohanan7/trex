defmodule MyProcess do
  use GenServer

  #External API
  def start do
    MySupervisor.start_process
  end

  def start_link() do
    GenServer.start_link(__MODULE__, [], [name: :myproc])
  end

  def kill(pid) do
    GenServer.cast(pid, :kill)
  end

  #Callbacks
  def init() do
    {:ok, [], 0}
  end

  def handle_info(_, state) do
    IO.inspect "my process"
  end

  def handle_cast(:kill, state) do
    {:stop, :shutdown, state}
  end
end


defmodule MySupervisor do
  use Supervisor

  def start_link do
    :supervisor.start_link({:local, :my_sup}, __MODULE__, [])
  end

  def init(_) do
    IO.inspect "starting my supervisor..."
    supervise([], strategy: :one_for_one)
  end

  def start_process do
    options = [id: make_ref(), strategy: :one_for_one, restart: :transient]
    :supervisor.start_child(:my_sup, worker(MyProcess, [], options))
  end

end


{:ok, sup} = MySupervisor.start_link
{:ok, proc} = MyProcess.start

MyProcess.kill :myproc
Supervisor.which_children sup

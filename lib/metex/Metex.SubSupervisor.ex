defmodule Metex.SubSupervisor do

  use Supervisor

  def start_link(hash_pid) do
    Supervisor.start_link(__MODULE__, hash_pid, name: __MODULE__)
  end

  # Supervisor Callbacks

  def init(hash_pid) do
    child_processes = [
      worker(Metex.Server, [hash_pid])
    ]
    supervise(child_processes, strategy: :one_for_one)
  end
end

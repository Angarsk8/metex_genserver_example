defmodule Metex.Supervisor do

  use Supervisor

  def start_link(initial_state) do
    result = {:ok, sup} = Supervisor.start_link(__MODULE__, initial_state, name: __MODULE__)
    start_children(sup, initial_state)
    result
  end

  defp start_children(sup, initial_state) do
    {:ok, stash} = Supervisor.start_child(sup, worker(Metex.Stash, [initial_state]))
    Supervisor.start_child(sup, supervisor(Metex.SubSupervisor, [stash]))
  end

  # Supervisor Callbacks

  def init(_) do
    supervise([], strategy: :one_for_one)
  end

end

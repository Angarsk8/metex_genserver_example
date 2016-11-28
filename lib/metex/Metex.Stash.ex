defmodule Metex.Stash do

  use GenServer

  def start_link(initial_state) do
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def get_state(pid) do
    GenServer.call(pid, :get_state)
  end

  def save_state(pid, state) do
    GenServer.cast(pid, {:save_state, state})
  end

  # GenServer Callbacks

  def handle_call(:get_state, _from, current_state) do
    {:reply, current_state, current_state}
  end

  def handle_cast({:save_state, state}, _current_state) do
    {:noreply, state}
  end
end

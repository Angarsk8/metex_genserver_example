defmodule Metex.Server do

  use GenServer

  import Metex.Server.Helpers, only: [temperature_of: 1, update_stats: 2]

  # Client API Implementation

  def start_link(stash_pid) do
    GenServer.start_link(__MODULE__, stash_pid, name: __MODULE__)
  end

  def get_temperature(location) do
    GenServer.call(__MODULE__, {:get_temperature, location})
  end

  def get_stats do
    GenServer.call(__MODULE__, :get_stats)
  end

  def reset_stats do
    GenServer.cast(__MODULE__, :reset_stats)
  end

  def stop do
    GenServer.cast(__MODULE__, :shutdown)
  end

  # GenServer Callbacks

  def init(stash_pid) do
    current_state = Metex.Stash.get_state(stash_pid)
    {:ok, {stash_pid, current_state}}
  end

  def handle_call({:get_temperature, location}, _from, state = {hash_pid, stats}) do
    case temperature_of(location) do
      {:ok, temperature} ->
        new_stats = update_stats(stats, location)
        {:reply, temperature, {hash_pid, new_stats}}
      :error ->
        {:reply, :error, state}
    end
  end
  def handle_call(:get_stats, _from, state = {_hash_pid, stats}) do
    {:reply, stats, state}
  end

  def handle_cast(:reset_stats, _state) do
    {:noreply, %{}}
  end
  def handle_cast(:shutdown, state) do
    {:stop, :shutdown, state}
  end

  def terminate(reason, state = {hash_pid, stats}) do
    Metex.Stash.save_state(hash_pid, stats)
    IO.puts "Shuting down the server (#{reason})..."
    {:noreply, state}
  end

  def handle_info(msg, state) do
    IO.puts "Received message #{inspect msg}"
    {:noreply, state}
  end
end

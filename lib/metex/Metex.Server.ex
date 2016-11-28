defmodule Metex.Server do

  use GenServer

  # Client API Implementation

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, [{:name, __MODULE__} | opts])
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

  # GenServer Implementation

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:get_temperature, location}, _from, stats) do
    case temperature_of(location) do
      {:ok, temperature} ->
        new_stats = update_stats(stats, location)
        {:reply, temperature, new_stats}
      :error ->
        {:reply, :error, stats}
    end
  end
  def handle_call(:get_stats, _from, stats) do
    {:reply, stats, stats}
  end

  def handle_cast(:reset_stats, _state) do
    {:noreply, %{}}
  end
  def handle_cast(:shutdown, stats) do
    {:stop, :shutdown, stats}
  end

  def terminate(reason, stats) do
    IO.puts "Server terminated because of #{inspect reason}"
    inspect stats
  end

  def handle_info(msg, state) do
    IO.puts "Received message #{inspect msg}"
    {:noreply, state}
  end

  # Helper Functions

  defp temperature_of(location) do
    location
    |> url_for
    |> HTTPoison.get
    |> handle_response
  end

  @api_url Application.get_env(:metex, :api_url)
  @api_key Application.get_env(:metex, :api_key)

  defp url_for(location) do
    "#{@api_url}#{location}&APPID=#{@api_key}"
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    body
    |> JSON.decode!
    |> format_response
  end
  defp handle_response(_) do
    :error
  end

  defp format_response(json) do
    try do
      {:ok, json["main"]["temp"]}
    rescue
      _ -> :error
    end
  end

  def update_stats(old_stats, location) do
    if Map.has_key?(old_stats, location) do
      Map.update!(old_stats, location, & &1 + 1)
    else
      Map.put(old_stats, location, 1)
    end
  end
end

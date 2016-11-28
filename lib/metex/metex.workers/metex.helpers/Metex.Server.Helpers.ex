defmodule Metex.Server.Helpers do

  @api_url Application.get_env(:metex, :api_url)
  @api_key Application.get_env(:metex, :api_key)

  def temperature_of(location) do
    location
    |> url_for
    |> HTTPoison.get
    |> handle_response
  end


  defp url_for(location) do
    "#{@api_url}#{location}&APPID=#{@api_key}"
  end

  defp handle_response({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    json = JSON.decode!(body)
    {:ok, json["main"]["temp"]}
  end
  defp handle_response(_) do
    :error
  end

  def update_stats(old_stats, location) do
    if Map.has_key?(old_stats, location) do
      Map.update!(old_stats, location, & &1 + 1)
    else
      Map.put(old_stats, location, 1)
    end
  end
end

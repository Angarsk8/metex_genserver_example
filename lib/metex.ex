defmodule Metex do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    :observer.start
    initial_state = Application.get_env(:metex, :initial_state)
    Metex.Supervisor.start_link(initial_state)
  end
end

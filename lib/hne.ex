defmodule HNE do

  use Application

  def start(_type, _args) do
    IO.inspect "Starting Hacker News Elixir/Erlang Notifier..."
    HNE.HNStories.fetch()
  end
end

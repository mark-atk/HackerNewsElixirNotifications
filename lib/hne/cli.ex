defmodule HNE.CLI do
  @moduledoc """
  following module is intended to be a command line interface that will include
  a help function and eventually capabilities for adding/removing emails and keywords.
  """

  @doc """
  kicks off main process
  """
  def process() do
    HNE.HNStories.fetch()
  end

end
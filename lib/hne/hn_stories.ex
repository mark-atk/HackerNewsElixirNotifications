defmodule HNE.HNStories do
  @moduledoc """
  This module pulls a list of the n top news stories from
  the HN firebase directory of Top News Stories, it then
  checks each news story title for 'Elixir' or 'Erlang'.
  """

  @doc """
  Fetch retrieves list of top HN news stories.
  """
  def fetch() do
    HTTPoison.get("https://hacker-news.firebaseio.com/v0/topstories.json?print=pretty")
    |> handle_firebase_list_response
    |> handle_string
    |> Enum.take(150)
    |> Enum.reverse() #start from most popular story
    |> HNE.StoryId.return_new
    |> get_stories()
  end


  @doc """
  Get_stories retrieves each news article from 
  the firebase locaiton and checks the title.

  When the incoming story list is empty it waits
  ten minutes and then runs again.
  """
  def get_stories([ story | tail ]) do
    story
    |> String.strip()
    |> firebase_url_get()
    |> HTTPoison.get
    |> decode_response
    |> handle_json
    |> handle_map

    get_stories(tail)
  end

  def get_stories([]) do 
    :timer.sleep(600000)
    fetch()
  end

  def get_stories(nil) do 
    IO.puts "FINISHED WITH NIL?"
  end

  @doc """
  handle_firebase_list_response receives the HTTPoison response and formats
  it for further processing.

  Returns a tuple { :ok, body } where body is a list of strings
  of article ID's with some bits on the ends that needs to be trimmed.
  """
  def handle_firebase_list_response({:ok, %{status_code: 200, body: body}}) do
    { :ok, body } 
  end

  def handle_firebase_list_response({_, %{status_code: _, body: body}}) do
    { :error, body } 
  end

  @doc """
  Handle_string cleans up the firebase list (comes in as string).

  Returns list of firebase story ID's
  """ 
  def handle_string({ :ok, body } ) do
    body
    |> String.replace("[ ", "")
    |> String.replace(" ]\\n", "")
    |> String.split(",")
  end

  def handle_string({ :error, body } ) do
    IO.puts "Error :  " <> body
  end

  @doc """
  Firebase_url_get generates the firebase url for that particular story.
  """
  def firebase_url_get(story) do
    "https://hacker-news.firebaseio.com/v0/item/#{story}.json?print=pretty"
  end

  @doc """
  Decode_response handles the httpoison get request from the firebase story link
  and parses the received JSON to a map.

  Returns tuple { :ok, body } where the body is the article details in map format.
  """
  def decode_response({ :ok, %{status_code: 200, body: body }}) do
    { :ok, Poison.Parser.parse!(body) }
  end

  def decode_response({ _, %{status_code: _, body: body }}) do
    { :error, Poison.Parser.parse!(body) }
  end

  @doc """
  Handle_json gets the map from http response and checks if
  the title field in the map contains the words 'erlang' & 'elixir'.

  Returns tuple { :ok, body } where body is the map if it does contain
  the keywords and 'nothing' if the article is not "interesting".
  """
  def handle_json({ :ok, body }) do
    { :ok, title } = Map.fetch(body, "title")

    if String.contains?(String.downcase(title), ["erlang", "elixir"]) do
      { :ok, body }
    else
      { :no, "nothing" }
    end
  end

  def handle_json({ :error, body }) do
    IO.puts "Error: #{body}"
  end

  @doc """
  handle_map handles the sending of the article or the printing of the 
  result to the console.

  If the article is elixir/erlang relevant the function prints
  the title of article and sends relevant email.

  If article is not "interesting" it just sends "nothing" to console.
  """
  def handle_map({ :ok, body }) do
    { :ok, resTitle } = Map.fetch(body, "title")
    { :ok, resLink } = Map.fetch(body, "url")

    #Send email with mailer.
    HNE.Mailer.deliver HNE.Mailer.sending_email(resTitle, resLink)

    IO.puts handle_date() <> " : " <> resTitle
  end

  def handle_map({ :no, body }) do
    IO.puts handle_date() <> " : " <> body
  end

  @doc """
  builds a datetime string from :calendar.
  """
  def handle_date() do
    {{ y, m, d }, { h, mm, s }} = :calendar.local_time()

    "#{y}/#{m}/#{d} #{h}:#{mm}:#{s}"
  end
end
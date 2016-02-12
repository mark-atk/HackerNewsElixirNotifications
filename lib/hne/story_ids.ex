defmodule HNE.StoryId do
  @moduledoc """
  This module keeps track of all story ids that have been checked in the past
  in a csv in the root folder.
  """

  @doc """
  Return list of id's that are not in the csv
  """
  def return_new(firebase_ids) do
    current = CSVLixir.read("story_ids.csv")
      |> Enum.to_list
      |> List.flatten

    return_new(current, firebase_ids, [])
  end

  def return_new(current, [head | tail], new_ids) do

    if(!find_val(current, head, false)) do
    
      new_ids = [head | new_ids]
      return_new(current, tail, new_ids)
    else
      return_new(current, tail, new_ids)
    end
  end

  def return_new(current, [], new_ids) do
    total_list = current ++ new_ids
    f = File.open!("story_ids.csv", [:write, :utf8])
      IO.write(f, CSVLixir.write_row(total_list))
      File.close(f)
      
    new_ids
  end

  @doc """
  check if value 'id_new' exists in list
  """
  def find_val([id | _tail], id_new, _) when id == id_new do
    find_val( [], id_new, true)
  end

  def find_val([id | tail], id_new, _) when id != id_new do
    find_val( tail, id_new, false)
  end

  def find_val( [], _, res) do
    res
  end
end
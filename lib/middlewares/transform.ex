defmodule Uex.Middlewares.Transform do
  import Mogrify

  @versions [:original, :medium, :thumb]

  def transform(%Uex{} = model, _) do
    @versions
    |> Enum.map(&transform_for_version(&1, model))
    |> Enum.map(&Uex.Preparer.prepare(&1, model))
  end

  def transform_for_version(:medium, %Uex{file_path: path, file_name: file_name}) do
    %{path: path} = open(path) |> resize("200x200") |> save()
    name = "medium_#{file_name}"

    Uex.new(path, file_name: name)
  end

  def transform_for_version(:thumb, %Uex{file_path: path, file_name: file_name}) do
    %{path: path} = open(path) |> resize("100x100") |> save()
    name = "thumb_#{file_name}"

    Uex.new(path, file_name: name)
  end

  def transform_for_version(:original, %Uex{} = model) do
    model
  end
end

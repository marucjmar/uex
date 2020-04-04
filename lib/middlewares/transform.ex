defmodule Uex.Middlewares.Transform do
  import Mogrify

  @versions [:original, :medium, :thumb]

  def transform(%Uex{} = model, _) do
    @versions
    |> Enum.map(&transform_for_version(&1, model))
    |> Enum.map(&Uex.Preparer.prepare(&1, model))
  end

  def transform_for_version(:original, %Uex{} = model) do
    model
  end

  def transform_for_version(version, %Uex{file_name: file_name} = model) do
    %{path: path} = transform_path(version, model)
    name = "#{version}_#{file_name}"

    Uex.new(path, file_name: name, tag: version)
  end

  def transform_path(:medium, %Uex{file_path: path}) do
    open(path) |> resize("200x200") |> save()
  end

  def transform_path(:thumb, %Uex{file_path: path}) do
    open(path) |> resize("100x100") |> save()
  end
end

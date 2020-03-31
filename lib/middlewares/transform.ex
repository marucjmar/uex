defmodule Uex.Middlewares.Transform do
  import Mogrify

  alias Uex.Models.UploadFile

  @versions [:medium, :thumb]

  def transform(%Uex{} = model, _) do
    @versions
    |> Enum.reduce(model, &transform_for_version/2)
  end

  def transform_for_version(:medium, %Uex{file_path: path, opts: opts} = model) do
    %{path: path} = open(path) |> resize("200x200") |> save()
    name = "medium_#{opts[:file_name]}"

    model
    |> Uex.add_file_to_upload(%UploadFile{file_path: path, name: name})
  end

  def transform_for_version(:thumb, %Uex{file_path: path, opts: opts} = model) do
    name = "thumb_#{opts[:file_name]}"

    %{path: path} = open(path) |> resize("100x100") |> save()

    model
    |> Uex.add_file_to_upload(%UploadFile{
      file_path: path,
      name: name
    })
  end
end

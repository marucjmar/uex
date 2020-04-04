defmodule DummyTest.AvatarUploader do
  import Uex.Composer

  alias DummyTest.CacheStore
  alias Mogrify

  def upload_com do
    Uex.new("https://upload.wikimedia.org/wikipedia/commons/9/92/Official_Elixir_logo.png")
    |> compose()
    |> validate_file_size(max: 8290)
    |> validate_extension([".jpg", ".jpeg", ".png"])
    |> validate_content_type(["image/png"])
    |> add_version(:medium, &transform/3)
    |> add_version(:thumb, &transform/3)
    |> CacheStore.store_all()
  end

  defp transform(:medium, %Uex{file_name: file_name, file_path: file_path}, _opts) do
    %{path: path} =
      Mogrify.open(file_path)
      |> Mogrify.resize("200x200")
      |> Mogrify.save()

    Uex.new(path, file_name: "medium_#{file_name}", tag: :medium)
  end

  defp transform(:thumb, %Uex{file_name: file_name, file_path: file_path}, _opts) do
    %{path: path} =
      Mogrify.open(file_path)
      |> Mogrify.resize("100x100")
      |> Mogrify.save()

    Uex.new(path, file_name: "thumb_#{file_name}", tag: :thumb)
  end
end

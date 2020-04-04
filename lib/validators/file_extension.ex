defmodule Uex.Validators.FileExtension do
  def validate(%Uex{} = model, extensions) do
    file_extension = Uex.get_extension(model)

    extensions
    |> Enum.member?(file_extension)
    |> case do
      true -> :ok
      false ->
        {:error, :invalid_extension}
    end
  end
end

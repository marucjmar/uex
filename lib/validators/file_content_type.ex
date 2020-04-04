defmodule Uex.Validators.FileContentType do
  def validate(%Uex{} = model, content_types) do
    file_content_type = Uex.get_content_type(model)

    content_types
    |> Enum.member?(file_content_type)
    |> case do
      true -> :ok
      false ->
        {:error, :invalid_content_type}
    end
  end
end

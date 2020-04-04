defmodule Uex.TestSourceResolver do
  @behaviour Uex.SourceResolver

  def resolve(%Uex{file_path: "/" <> _} = model) do
    model
  end

  def resolve(%Uex{source: %Plug.Upload{path: path, filename: filename}} = model) do
    %Uex{model | file_path: path, file_name: filename}
  end

  def resolve(%Uex{source: "http://fail.png"}) do
    {:error, :unresolved}
  end

  def resolve(%Uex{source: "http" <> _ = url} = model) do
    %Uex{
      model
      | file_path: "test/fixtures/elixir_logo.png",
        file_name: model.file_name || Path.basename(url)
    }
  end

  def resolve(%Uex{source: path} = model) when is_binary(path) do
    %Uex{model | file_path: path, file_name: model.file_name || Path.basename(path)}
  end
end

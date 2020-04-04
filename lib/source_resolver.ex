defmodule Uex.SourceResolver do
  @callback resolve(Uex.t()) :: Uex.t() | {:error, atom()}

  def resolve(%Uex{file_path: "/" <> _} = model) do
    model
  end

  def resolve(%Uex{source: %Plug.Upload{path: path, filename: filename}} = model) do
    %Uex{model | file_path: path, file_name: filename}
  end

  def resolve(%Uex{source: "http" <> _ = url} = model) do
    with {:ok, %HTTPoison.Response{body: body}} <- HTTPoison.get(url),
         {:ok, tmp_path} = Temp.path(),
         :ok <- File.write(tmp_path, body) do
      %Uex{model | file_path: tmp_path, file_name: model.file_name || Path.basename(url)}
    else
      reply ->
        reply
    end
  end

  def resolve(%Uex{source: "/" <> _ = path} = model) do
    %Uex{model | file_path: path, file_name: model.file_name || Path.basename(path)}
  end
end

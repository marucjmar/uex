defmodule Uex.Preparer do
  def prepare(%Uex{source: %Plug.Upload{path: path} = plug_upload} = model, store_opts) do
    %Uex{model | file_path: path}
    |> Map.put(:file_name, plug_upload.filename)
    |> _prepare(store_opts)
  end

  def prepare(%Uex{source: "http" <> _ = url} = model, store_opts) do
    with {:ok, %HTTPoison.Response{body: body}} <- HTTPoison.get(url),
         {:ok, tmp_path} = Temp.path(),
         :ok <- File.write(tmp_path, body) do
      %Uex{model | file_path: tmp_path}
      |> Map.put(:file_name, model.file_name || Path.basename(url))
      |> _prepare(store_opts)
    else
      reply ->
        reply
    end
  end

  def prepare(%Uex{source: path} = model, store_opts) when is_binary(path) do
    %Uex{model | file_path: path}
    |> Map.put(:file_name, model.file_name || Path.basename(path))
    |> _prepare(store_opts)
  end

  defp _prepare(%Uex{} = uex, provided_opts) do
    uex
    |> put_opts(provided_opts)
    |> put_meta()
  end

  defp put_meta(%Uex{file_path: path, file_name: file_name} = uex) do
    with {:ok, %File.Stat{} = stat} <- File.stat(path) do
      uex
      |> Uex.set_extension(Path.extname(file_name || path))
      |> Uex.set_content_type(MIME.from_path(file_name))
      |> Uex.set_file_size(stat.size)
    end
  end

  defp put_opts(%Uex{opts: opts} = uex, provided_opts) do
    %Uex{uex | opts: Keyword.merge(provided_opts, opts)}
  end
end

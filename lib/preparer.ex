defmodule Uex.Preparer do
  import Uex, only: [put_new_opts: 3]

  def prepare(%Uex{source: %Plug.Upload{path: path} = plug_upload} = model, _store_opts) do
    %Uex{model | file_path: path}
    |> Map.put(:file_name, plug_upload.file_name)
    |> _prepare()
  end

  def prepare(%Uex{source: "http" <> _ = url} = model, _store_opts) do
    with {:ok, %HTTPoison.Response{body: body}} <- HTTPoison.get(url),
         {:ok, tmp_path} = Temp.path(),
         :ok <- File.write(tmp_path, body) do
      %Uex{model | file_path: tmp_path}
      |> Map.put(:file_name, model.file_name || Path.basename(url))
      |> _prepare()
    else
      reply ->
        reply
    end
  end

  def prepare(%Uex{source: path} = model, _store_opts) when is_binary(path) do
    %Uex{model | file_path: path}
    |> Map.put(:file_name, model.file_name || Path.basename(path))
    |> _prepare()
  end

  def _prepare(%Uex{} = uex) do
    uex
    |> put_meta()
  end

  defp put_meta(%Uex{file_path: path, file_name: file_name} = uex) do
    with {:ok, %File.Stat{} = stat} <- File.stat(path) do
      uex
      |> Uex.set_extension(Path.extname(file_name) || Path.extname(path))
      |> Uex.set_content_type(MIME.from_path(file_name))
      |> Uex.set_file_size(stat.size)
    end
  end
end

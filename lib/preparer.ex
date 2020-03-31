defmodule Uex.Preparer do
  alias Uex

  def prepare(
        %Uex{source: %Plug.Upload{path: path} = plug_upload, opts: opts} = model,
        _store_opts
      ) do
    opts =
      opts
      |> Keyword.put_new(:file_name, plug_upload.file_name)

    %Uex{model | file_path: path, opts: opts}
    |> _prepare()
  end

  def prepare(%Uex{source: "http" <> _ = url, opts: opts} = model, _store_opts) do
    with {:ok, %HTTPoison.Response{body: body}} <- HTTPoison.get(url),
         {:ok, tmp_path} = Temp.path(),
         :ok <- File.write(tmp_path, body) do
      opts =
        opts
        |> Keyword.put_new(:file_name, Path.basename(url))

      %Uex{model | opts: opts, file_path: tmp_path}
      |> _prepare()
    else
      reply ->
        reply
    end
  end

  def prepare(%Uex{source: path} = model, _store_opts) when is_binary(path) do
    %Uex{model | file_path: path}
    |> _prepare()
  end

  def _prepare(%Uex{} = uex) do
    uex
  end
end

defmodule Uex.Preparer do
  def prepare(%Uex{} = model, resolver, provided_opts) do
    model
    |> resolver.resolve()
    |> put_opts(provided_opts)
    |> put_meta()
  end

  defp put_opts(%Uex{opts: opts} = uex, provided_opts) do
    %Uex{uex | opts: Keyword.merge(provided_opts, opts)}
  end

  defp put_opts(reply, _), do: reply

  defp put_meta(%Uex{file_path: path, file_name: file_name} = uex) do
    with {:ok, %File.Stat{} = stat} <- File.stat(path) do
      uex
      |> Uex.set_extension(Path.extname(file_name || path))
      |> Uex.set_content_type(MIME.from_path(file_name))
      |> Uex.set_file_size(stat.size)
    end
  end

  defp put_meta(reply), do: reply
end

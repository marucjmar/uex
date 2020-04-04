defmodule Uex.Adapter.Test do
  @config_opts []

  alias Uex.Models.UploadedFile

  def prepare_opts(opts) do
    @config_opts
    |> Enum.reduce([], fn opt, acc ->
      acc
      |> Keyword.put_new(opt, Keyword.fetch!(opts, opt))
    end)
  end

  def uex_opts_keys() do
  end

  def upload_file(%Uex{file_path: path, file_name: file_name, opts: opts, tag: tag}, _store) do
    %UploadedFile{url: path, name: file_name, opts: opts, tag: tag}
  end

  def url_for_resource(model, _) do
    model
  end
end

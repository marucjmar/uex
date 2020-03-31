defmodule Uex.Adapter.S3 do
  @config_opts [:bucket, :access_key_id, :secret_access_key, :region]

  alias Uex
  alias Uex.Models.UploadFile
  alias Uex.Models.UploadedFile

  def prepare_opts(opts) do
    @config_opts
    |> Enum.reduce([], fn opt, acc ->
      acc
      |> Keyword.put_new(opt, Keyword.fetch!(opts, opt))
    end)
  end

  def upload_file(
        %UploadFile{file_path: path, name: file_name, opts: opts} = upload_file,
        %{adapter_opts: adapter_opts},
        default_opts
      ) do
    opts =
      default_opts
      |> Keyword.merge(opts)

    s3_opts =
      opts
      |> Keyword.get(:s3, [])

    path
    |> ExAws.S3.Upload.stream_file()
    |> ExAws.S3.upload(
      Keyword.get(adapter_opts, :bucket),
      Path.join(Keyword.get(opts, :upload_directory), file_name),
      s3_opts
    )
    |> ExAws.request!(
      access_key_id: Keyword.get(adapter_opts, :access_key_id),
      secret_access_key: Keyword.get(adapter_opts, :secret_access_key),
      region: Keyword.get(adapter_opts, :region)
    )
    |> prepare_model(upload_file)
  end

  defp prepare_model(%{status_code: 200}, %UploadFile{file_path: path, name: name}) do
    %UploadedFile{url: path, name: name}
  end

  defp prepare_model(_, _) do
    {:error, :error}
  end

  # defp url_for_resource(%UploadFile{}) do
  #   Path.join(adapter.upload_directory, file_name)
  # end
end

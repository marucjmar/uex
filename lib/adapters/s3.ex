defmodule Uex.Adapter.S3 do
  @config_opts [:bucket, :access_key_id, :secret_access_key, :region]

  alias Uex
  alias Uex.Models.UploadedFile

  def prepare_opts(opts) do
    @config_opts
    |> Enum.reduce([], fn opt, acc ->
      acc
      |> Keyword.put_new(opt, Keyword.fetch!(opts, opt))
    end)
  end

  def upload_file(
        %Uex{file_path: path, file_name: file_name, opts: opts} = upload_file,
        %{adapter_opts: adapter_opts} = store,
        default_opts
      ) do
    opts =
      default_opts
      |> Keyword.merge(opts)

    s3_opts =
      opts
      |> Keyword.get(:default_opts)
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
    |> prepare_model(upload_file, opts, store)
  end

  defp prepare_model(%{status_code: 200}, %Uex{file_name: name} = uex, opts, store) do
    url =
      "https://" <>
        Keyword.get(store.adapter_opts, :bucket) <>
        ".s3." <>
        Keyword.get(store.adapter_opts, :region) <>
        ".amazonaws.com" <> Path.join(Keyword.get(opts, :upload_directory), name)

    %UploadedFile{url: url}
    |> Map.put(:name, name)
    |> Map.put(:storage, store.name)
    |> Map.put(:size, Uex.get_file_size(uex))
    |> Map.put(:extension, Uex.get_extension(uex))
    |> Map.put(:content_type, Uex.get_content_type(uex))
    |> Map.put(:tag, uex.tag)
  end

  defp prepare_model(_, _, _, _) do
    {:error, :error}
  end

  # defp url_for_resource(%Uex{}) do
  #   Path.join(adapter.upload_directory, file_name)
  # end
end

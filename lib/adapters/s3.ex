defmodule Uex.Adapter.S3 do
  @config_opts [:bucket, :access_key_id, :secret_access_key, :region]

  alias Uex.Models.UploadedFile

  def prepare_opts(opts) do
    @config_opts
    |> Enum.reduce([], fn opt, acc ->
      acc
      |> Keyword.put_new(opt, Keyword.fetch!(opts, opt))
    end)
  end

  def uex_opts_keys() do
    [:s3]
  end

  def upload_file(%Uex{file_path: path, file_name: file_name, opts: opts} = uex, store) do
    path
    |> ExAws.S3.Upload.stream_file()
    |> ExAws.S3.upload(
      Keyword.get(store.adapter_opts, :bucket),
      Path.join(Uex.get_upload_directory(uex), file_name),
      s3_params(uex)
    )
    |> ExAws.request!(
      access_key_id: Keyword.get(store.adapter_opts, :access_key_id),
      secret_access_key: Keyword.get(store.adapter_opts, :secret_access_key),
      region: Keyword.get(store.adapter_opts, :region)
    )
    |> prepare_model(uex, store)
  end

  defp s3_params(%Uex{opts: opts} = uex) do
    s3_opts = Keyword.get(opts, :s3)

    Keyword.merge([content_type: Uex.get_content_type(uex)], s3_opts)
  end

  defp prepare_model(%{status_code: 200}, %Uex{file_name: name} = uex, store) do
    url = url_for_resource(uex, store)

    %UploadedFile{url: url}
    |> Map.put(:name, name)
    |> Map.put(:storage, store.name)
    |> Map.put(:size, Uex.get_file_size(uex))
    |> Map.put(:extension, Uex.get_extension(uex))
    |> Map.put(:content_type, Uex.get_content_type(uex))
    |> Map.put(:tag, uex.tag)
    |> Map.put(:opts, uex.opts)
  end

  defp prepare_model(_, _, _, _) do
    {:error, :error}
  end

  def url_for_resource(%Uex{file_name: name, opts: opts}, store) do
    domain =
      "https://" <>
        Keyword.get(store.adapter_opts, :bucket) <>
        ".s3." <>
        Keyword.get(store.adapter_opts, :region) <>
        ".amazonaws.com"

    path = Path.join(Keyword.get(opts, :upload_directory), name)

    Path.join(domain, path)
  end

  def url_for_resource(%UploadedFile{} = uploaded_file, store) do
    uploaded_file
    |> UploadedFile.to_uex()
    |> url_for_resource(store)
  end
end

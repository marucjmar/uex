defmodule Uex.Uploader do
  alias Uex
  alias Uex.Models.UploadFile
  alias Uex.Models.UploadedFile

  def store(
        %Uex{opts: opts},
        %{adapter_module: adapter_mod} = store,
        store_opts
      ) do
    with [%UploadFile{} = upload_file] <-
           Keyword.get(opts, :files_to_upload, {:error, :blank_file}) do
      adapter_mod.upload_file(upload_file, store, store_opts)
    else
      [%UploadFile{} | _] ->
        {:error, :collection_privided}

      reply ->
        reply
    end
    |> prepare_response()
  end

  def store(reply, _), do: reply

  def store_all(
        %Uex{opts: opts},
        %{adapter_module: adapter_mod} = store,
        store_opts
      ) do
    opts
    |> Keyword.get(:files_to_upload, [])
    |> Task.async_stream(&adapter_mod.upload_file(&1, store, store_opts))
    |> Enum.to_list()
    |> prepare_response()
  end

  def prepare_response({:error, _} = error), do: error

  def prepare_response([_ | _] = response) do
    Enum.all?(response, fn
      {:ok, %UploadedFile{}} -> true
      _ -> false
    end)
    |> case do
      true ->
        {:ok, Enum.map(response, fn {_k, v} -> v end)}

      error ->
        error
    end
  end

  def prepare_response(%UploadedFile{} = response), do: {:ok, response}
end

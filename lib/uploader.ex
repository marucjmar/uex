defmodule Uex.Uploader do
  alias Uex
  alias Uex.Models.UploadedFile

  def store(
        %Uex{} = uex,
        %{adapter_module: adapter_mod} = store,
        store_opts
      ) do
    uex
    |> adapter_mod.upload_file(store, store_opts)
    |> prepare_response()
  end

  def store([_], _, _), do: {:error, :multiple_files_provided}

  def store(reply, _, _), do: reply

  def store_all(
        [%Uex{} | _] = models,
        %{adapter_module: adapter_mod} = store,
        store_opts
      ) do
    models
    |> Task.async_stream(&adapter_mod.upload_file(&1, store, store_opts))
    |> Enum.to_list()
    |> prepare_response()
  end

  def store_all(%Uex{}, _, _), do: {:error, :single_file_provided}

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

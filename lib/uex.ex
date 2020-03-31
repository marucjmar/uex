defmodule Uex do
  defstruct [:source, :opts, :file_path, :files_to_upload, middlewares: []]
  alias Uex.Models.UploadFile

  def new(source, opts \\ [])

  def new(source, opts) do
    %__MODULE__{source: source, opts: opts}
  end

  def add_middleware(%__MODULE__{} = model, callback) do
    update_opts(model, :middlewares, callback)
  end

  def add_file_to_upload(%__MODULE__{} = model, %UploadFile{} = file) do
    update_opts(model, :files_to_upload, file)
  end

  defp update_opts(%__MODULE__{opts: opts} = model, key, value) do
    model
    |> Map.put(:opts, Keyword.update(opts, key, [value], &(&1 ++ [value])))
  end
end

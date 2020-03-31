defmodule Uex do
  defstruct [:source, :opts, :file_path, :files_to_upload, middlewares: []]
  alias Uex.Models.UploadFile

  def new(source, opts \\ [])

  def new(source, opts) do
    %__MODULE__{source: source, opts: opts}
  end

  def add_middleware(%__MODULE__{opts: opts} = model, callback) do
    model
    |> Map.update(:middlewares, [callback], &(&1 ++ [callback]))
  end

  def add_file_to_upload(%__MODULE__{opts: opts} = model, %UploadFile{file_path: path} = file) do
    opts =
      opts
      |> Keyword.update(:files_to_upload, [file], &(&1 ++ [file]))

    %__MODULE__{model | opts: opts}
  end
end

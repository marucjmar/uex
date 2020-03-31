defmodule Uex.Middlewares.CreateOriginalFile do
  import Mogrify

  alias Uex.Models.UploadFile

  def call(%Uex{file_path: path, opts: opts} = model, _) do
    model
    |> Uex.add_file_to_upload(%UploadFile{
      file_path: path,
      name: opts[:file_name]
    })
  end
end

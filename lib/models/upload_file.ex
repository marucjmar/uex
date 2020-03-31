defmodule Uex.Models.UploadFile do
  @enforce_keys [:file_path, :name]

  defstruct [:file_path, :name, :storage_dir, opts: []]
end

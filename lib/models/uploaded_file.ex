defmodule Uex.Models.UploadedFile do
  @enforce_keys [:url]

  defstruct [:url, :storage, :opts, :extension, :name, :size]
end

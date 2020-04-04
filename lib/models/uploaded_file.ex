defmodule Uex.Models.UploadedFile do
  @enforce_keys [:url]

  defstruct [:url, :storage, :opts, :extension, :name, :size, :content_type, :tag]

  def to_uex(%__MODULE__{url: url, opts: opts, name: name}) do
    %Uex{source: url, opts: opts, file_name: name}
  end
end

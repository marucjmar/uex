defmodule Uex.StorageTest do
  use Uex.FileStorage,
    otp_app: :uex,
    adapter: Uex.Adapter.Test,
    upload_directory: "/test"
end

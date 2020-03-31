defmodule Uex.Storage do
  use Uex.FileStorage,
    adapter: Uex.Adapter.S3,
    bucket: "uex",
    upload_directory: "/dev",
    access_key_id: "xxxxx",
    secret_access_key: "xxxxxx",
    region: "eu-north-1",
    default_opts: [
      s3: [acl: :public_read]
    ]
end

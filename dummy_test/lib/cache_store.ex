defmodule DummyTest.CacheStore do
  use Uex.FileStorage,
    otp_app: :dummy_test,
    adapter: Uex.Adapter.S3,
    upload_directory: "/devxw",
    default_opts: [
      s3: [acl: :public_read]
    ]
end

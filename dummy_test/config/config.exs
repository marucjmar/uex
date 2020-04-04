use Mix.Config

config :dummy_test, DummyTest.CacheStore,
  bucket: "uex",
  access_key_id: "xxxxxxxxx",
  secret_access_key: "xxxxxxxxxxx",
  region: "eu-north-1",
  upload_directory: "/dev",
  s3: [acl: :public_read]

import_config "dev.secre*.exs"

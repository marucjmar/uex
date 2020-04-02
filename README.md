# Uex in development stage!

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `uex` to your list of dependencies in `mix.exs`:

#### mix.exs

```elixir
def deps do
  [
    {:uex, "~> 0.0.1"}
  ]
end
```

#### config.ex

```elixir
config :my_app, MyApp.Storage,
  access_key_id: "xxxxx",
  secret_access_key: "xxxxxx",
  region: "eu-north-1",
  bucket: "uex"
```

#### lib/storage.ex

```elixir
defmodule MyApp.Storage do
  use Uex.FileStorage,
    otp_app: :my_app,
    adapter: Uex.Adapter.S3,
    upload_directory: "/dev",
    default_opts: [
      s3: [acl: :public_read]
    ]
end
```

## Simple upload

```elixir
#iex>
Uex.new("https://upload.wikimedia.org/wikipedia/commons/9/92/Official_Elixir_logo.png")
|> MyApp.Storage.store()
# {:ok, %Uex.Models.UploadedFile{}}
```

## Middlewares

### Cutom per operation

```elixir
defmodule MyApp.Transform do
  def rename_file(%Uex{} = uploader, _) do
    uploader
    |> Uex.put_opts(:file_name, "my_new_file_name")
  end
end

Uex.new("https://upload.wikimedia.org/wikipedia/commons/9/92/Official_Elixir_logo.png")
|> Uex.add_middleware(&MyApp.Transform.rename_file/2)
|> Uex.add_middleware(&Uex.Middlewares.Transform.transform/2)
|> MyApp.Storage.store_all()
# {:ok, [%Uex.Models.UploadedFile{}, %Uex.Models.UploadedFile{}]}
```

### Custom per store

```elixir
defmodule MyApp.Storage do
  use Uex.FileStorage,
    otp_app: :my_app,
    adapter: Uex.Adapter.S3,
    upload_directory: "/dev",
    middlewares: Uex.FileStorage.default_middlewares() ++ [&MyMiddleware.call/2],
    default_opts: [
      s3: [acl: :public_read]
    ]
end
```

## Override store options before upload

```elixir
#iex>
Uex.new("https://upload.wikimedia.org/wikipedia/commons/9/92/Official_Elixir_logo.png")
|> MyApp.Storage.store(middlewares: [], sotrage_dir: "/foo/bar", s3: [acl: :private])
# {:ok, %Uex.Models.UploadedFile{}}
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/uex](https://hexdocs.pm/uex).

# Uex in development stage

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `uex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:uex, "~> 0.1.0"}
  ]
end
```

```elixir
defmodule MyApp.Storage do
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

#iex>
Uex.new("https://upload.wikimedia.org/wikipedia/commons/9/92/Official_Elixir_logo.png",
  file_name: UUID.uuid4()
)
|> MyApp.Storage.Storage.store()
# {:ok, %Uex.Models.UploadedFile{}}
```

# Middlewares

```elixir
defmodule MyApp.Transform do
  def rename_file(%Uex{file_path: path, file_name: file_name} = model, _) do
    %Uex{model | file_name: file_name <> "<-my_awesome_file"}
  end
end

Uex.new("https://upload.wikimedia.org/wikipedia/commons/9/92/Official_Elixir_logo.png",
  file_name: UUID.uuid4()
)
|> Uex.add_middleware(&MyApp.Transform.rename_file/2)
|> Uex.add_middleware(&Uex.Middlewares.Transform.transform/2)
|> MyApp.Storage.Storage.store()
# {:ok, %Uex.Models.UploadedFile{}}
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/uex](https://hexdocs.pm/uex).

# Uex in development stage!

**TODO: Unit tests

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
    s3: [acl: :public_read]
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

### per operation

```elixir
defmodule MyApp.Transform do
  def rename_file(%Uex{} = uploader, _) do
    uploader
    |> Uex.put_opts(:file_name, "my_new_file_name")
  end
end

Uex.new("https://upload.wikimedia.org/wikipedia/commons/9/92/Official_Elixir_logo.png")
|> MyApp.Storage.store(middlewares: [&MyApp.Transform.rename_file/2])
# {:ok, [%Uex.Models.UploadedFile{}, %Uex.Models.UploadedFile{}]}
```

### per store

```elixir
defmodule MyApp.Storage do
  use Uex.FileStorage,
    otp_app: :my_app,
    adapter: Uex.Adapter.S3,
    upload_directory: "/dev",
    middlewares: [&MyMiddleware.call/2]
end
```

## Override store options before upload

```elixir
#iex>
Uex.new("https://upload.wikimedia.org/wikipedia/commons/9/92/Official_Elixir_logo.png")
|> MyApp.Storage.store(strage_dir: "/foo/bar", s3: [acl: :private])
# {:ok, %Uex.Models.UploadedFile{}}
```

## Composer

```elixir
defmodule MyApp.AvatarUploader do
  import Uex.Composer

  alias DummyTest.CacheStore
  alias Mogrify

  def upload_com do
    Uex.new("https://upload.wikimedia.org/wikipedia/commons/9/92/Official_Elixir_logo.png")
    |> compose()
    |> validate_file_size(max: 8290)
    |> validate_extension([".jpg", ".jpeg", ".png"])
    |> validate_content_type(["image/png"])
    |> add_version(:medium, &transform/3)
    |> add_version(:thumb, &transform/3)
    |> CacheStore.store_all()
  end

  defp transform(:medium, %Uex{file_name: file_name, file_path: file_path}, _opts) do
    %{path: path} = 
      Mogrify.open(file_path)
      |> Mogrify.resize("200x200") 
      |> Mogrify.save()

    Uex.new(path, file_name: "medium_#{file_name}", tag: :medium)
  end

  defp transform(:thumb, %Uex{file_name: file_name, file_path: file_path}, _opts) do
    %{path: path} = 
      Mogrify.open(file_path)
      |> Mogrify.resize("100x100") 
      |> Mogrify.save()

    Uex.new(path, file_name: "thumb_#{file_name}", tag: :thumb)
  end
end


#iex> MyApp.AvatarUploader.upload()
```

##System design
![System design](docs/system_design.png?raw=true)

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/uex](https://hexdocs.pm/uex).

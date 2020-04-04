defmodule DummyTest.AvatarUploader do
  alias DummyTest.CacheStore
  alias Uex.Composer
  import Uex.Composer

  def upload do
    Uex.new("https://upload.wikimedia.org/wikipedia/commons/9/92/Official_Elixir_logo.png")
    |> CacheStore.store(middlewares: [])
  end

  def upload_com do
    Uex.new("https://upload.wikimedia.org/wikipedia/commons/9/92/Official_Elixir_logo.png")
    |> compose()
    |> validate_file_size(max: 8290)
    |> validate_extension([".jpg", ".jpeg", ".png"])
    |> validate_content_type(["image/png"])
    |> add_middleware(&Uex.Middlewares.Transform.transform/2)
    |> CacheStore.store_all()
  end

  def upload_pipeline do
    Uex.new("https://upload.wikimedia.org/wikipedia/commons/9/92/Official_Elixir_logo.png")
    |> DummyTest.PipelinerUploader.pipe(:cache)
    |> DummyTest.PipelinerUploader.pipe(:store)
  end
end

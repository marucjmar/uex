defmodule DummyTest.AvatarUploader do
  alias DummyTest.CacheStore

  def upload do
    Uex.new("https://upload.wikimedia.org/wikipedia/commons/9/92/Official_Elixir_logo.png")
    |> CacheStore.store()
  end

  def upload_pipeline do
    Uex.new("https://upload.wikimedia.org/wikipedia/commons/9/92/Official_Elixir_logo.png")
    |> DummyTest.PipelinerUploader.pipe(:cache)
    |> DummyTest.PipelinerUploader.pipe(:store)
  end
end

defmodule DummyTest.AvatarUploader do
  alias DummyTest.CacheStore

  def upload do
    Uex.new("https://upload.wikimedia.org/wikipedia/commons/9/92/Official_Elixir_logo.png")
    |> CacheStore.store()
  end
end

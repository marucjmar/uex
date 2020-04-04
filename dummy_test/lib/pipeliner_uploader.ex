defmodule DummyTest.PipelinerUploader do
  import Uex.Pipeliner

  defdelegate pipe(source, stage), to: Uex.Pipeliner

  stage :cache do
    validate_extension([".jpg", ".jpeg", ".png"])
    validate_size(2000, :mb)
    persist(CacheStore)
  end

  stage :store do
    transform([1000, 2000])
    transform([1000, 2000])
    rename_file("asdsadda.jpg")
    move_to(PersistentStore)
    # copy_to(PersistentStore)
  end
end

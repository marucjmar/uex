defmodule Uex.PreparerTest do
  use ExUnit.Case

  alias Uex.Preparer

  doctest Uex.Preparer

  describe "for %Plug.Upload{} source" do
    setup do
      source = %Plug.Upload{path: "test/fixtures/elixir_logo.png", filename: "logo.png"}
      resolver = Uex.TestSourceResolver
      [model: Uex.new(source), source: source, resolver: resolver]
    end

    test "should created %Uex{} struct", context do
      opts = [upload_direcotry: "/dev"]

      assert Preparer.prepare(context[:model], context[:resolver], opts) == %Uex{
               source: context[:source],
               file_name: context[:source].filename,
               file_path: context[:source].path,
               tag: :original,
               opts: opts,
               meta: [file_size: 8290, content_type: "image/png", extension: ".png"]
             }
    end
  end

  describe "for url source" do
    setup do
      source = "https://upload.wikimedia.org/wikipedia/commons/9/92/Official_Elixir_logo.png"
      resolver = Uex.TestSourceResolver

      [model: Uex.new(source), source: source, resolver: resolver]
    end

    test "should created %Uex{} struct", context do
      opts = [upload_direcotry: "/dev"]

      assert %Uex{
               source: context[:source],
               file_name: "Official_Elixir_logo.png",
               file_path: "test/fixtures/elixir_logo.png",
               tag: :original,
               opts: opts,
               meta: [file_size: 8290, content_type: "image/png", extension: ".png"]
             } == Preparer.prepare(context[:model], context[:resolver], opts)
    end

    test "should created temp file", context do
      uex = Preparer.prepare(context[:model], context[:resolver], [])

      assert File.stat!(uex.file_path)
    end

    test "should return error when file not found", context do
      assert {:error, :unresolved} ==
               Preparer.prepare(
                 %Uex{context[:model] | source: "http://fail.png"},
                 context[:resolver],
                 []
               )
    end
  end

  describe "for file path source" do
    setup do
      source = Path.expand("test/fixtures/elixir_logo.png")
      resolver = Uex.TestSourceResolver

      [model: Uex.new(source), source: source, resolver: resolver]
    end

    test "should created %Uex{} struct", context do
      opts = [upload_direcotry: "/dev"]

      assert Preparer.prepare(context[:model], context[:resolver], opts) == %Uex{
               source: context[:source],
               file_name: "elixir_logo.png",
               file_path: context[:source],
               tag: :original,
               opts: opts,
               meta: [file_size: 8290, content_type: "image/png", extension: ".png"]
             }
    end
  end
end

defmodule Uex.PreparerTest do
  use ExUnit.Case

  doctest Uex.Preparer

  describe "for %Plug.Upload{} source" do
    setup do
      source = %Plug.Upload{path: "test/fixtures/elixir_logo.png", filename: "logo.png"}
      [model: Uex.new(source), source: source]
    end

    test "should created %Uex{} struct", context do
      opts = [upload_direcotry: "/dev"]

      assert Uex.Preparer.prepare(context[:model], opts) == %Uex{
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
      [model: Uex.new(source), source: source]
    end

    test "should created %Uex{} struct", context do
      opts = [upload_direcotry: "/dev"]

      assert %Uex{
               source: context[:source],
               file_name: "Official_Elixir_logo.png",
               file_path: "",
               tag: :original,
               opts: opts,
               meta: [file_size: 8290, content_type: "image/png", extension: ".png"]
             } == Uex.Preparer.prepare(context[:model], opts)
    end

    test "should created temp file", context do
      uex = Uex.Preparer.prepare(context[:model], [])

      assert File.stat(uex.file_path)
    end
  end

  describe "for file path source" do
    setup do
      source = Path.expand("test/fixtures/elixir_logo.png")

      [model: Uex.new(source), source: source]
    end

    test "should created %Uex{} struct", context do
      opts = [upload_direcotry: "/dev"]

      assert Uex.Preparer.prepare(context[:model], opts) == %Uex{
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

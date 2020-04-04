defmodule Uex.UploaderTest do
  use ExUnit.Case
  alias Uex.Uploader
  alias Uex.Models.UploadedFile
  alias Uex.StorageTest

  doctest Uex.Uploader

  describe "store/2" do
    setup do
      store = StorageTest
      source = Path.expand("test/fixtures/elixir_logo.png")
      uex = Uex.new(source) |> Uex.Preparer.prepare([])

      [uex: uex, store: store, source: source]
    end

    test "should create struct from params", context do
      assert Uploader.store(context[:uex], %StorageTest{}) ==
               {:ok,
                %UploadedFile{
                  url: context[:source],
                  tag: :original,
                  name: "elixir_logo.png",
                  opts: []
                }}
    end

    test "should return error when provided list of uex", context do
      assert {:error, :multiple_files_provided} ==
               Uploader.store([context[:uex], context[:uex]], %StorageTest{})
    end

    test "should return error when provided error" do
      error = {:error, :custom_error}

      assert error == Uploader.store(error, %StorageTest{})
    end
  end

  describe "store_all/2" do
    setup do
      store = StorageTest
      source = Path.expand("test/fixtures/elixir_logo.png")
      uex = Uex.new(source) |> Uex.Preparer.prepare([])

      [uex: uex, store: store, source: source]
    end

    test "should create structs from params", context do
      model = %UploadedFile{
        url: context[:source],
        tag: :original,
        name: "elixir_logo.png",
        opts: []
      }

      assert Uploader.store_all([context[:uex], context[:uex]], %StorageTest{}) ==
               {:ok, [model, model]}
    end

    test "should return error when provided single uex model", context do
      assert {:error, :single_file_provided} ==
               Uploader.store_all(context[:uex], %StorageTest{})
    end

    test "should return error when provided error" do
      error = {:error, :custom_error}

      assert error == Uploader.store_all(error, %StorageTest{})
    end
  end
end

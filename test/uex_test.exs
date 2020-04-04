defmodule UexTest do
  use ExUnit.Case

  doctest Uex

  describe "new/2" do
    test "should create struct from params" do
      source = "/var/lib/exs.mp4"
      file_name = UUID.uuid4()
      tag = UUID.uuid4()
      opts = [upload_directory: UUID.uuid4()]

      assert %Uex{source: source, file_name: file_name, tag: tag, opts: opts} ==
               Uex.new(source, file_name: file_name, tag: tag, opts: opts)
    end

    test "should set tag to :original by default" do
      source = "/var/lib/exs.mp4"
      file_name = UUID.uuid4()
      opts = [upload_directory: UUID.uuid4()]

      assert %Uex{source: _, tag: :original} = Uex.new(source, file_name: file_name, opts: opts)
    end
  end

  test "get_extension/1" do
    extension = Faker.File.file_extension(:audio)

    assert %Uex{source: "", meta: [extension: extension]} |> Uex.get_extension() == extension
  end

  test "set_extension/1" do
    extension = Faker.File.file_extension(:audio)

    assert %Uex{source: ""} |> Uex.set_extension(extension) == %Uex{
             source: "",
             meta: [extension: extension]
           }
  end

  test "get_content_type/1" do
    content_type = Faker.File.mime_type()

    assert %Uex{source: "", meta: [content_type: content_type]} |> Uex.get_content_type() ==
             content_type
  end

  test "set_content_type/1" do
    content_type = Faker.File.mime_type()

    assert %Uex{source: ""} |> Uex.set_content_type(content_type) == %Uex{
             source: "",
             meta: [content_type: content_type]
           }
  end

  test "get_file_size/1" do
    file_size = 123

    assert %Uex{source: "", meta: [file_size: file_size]} |> Uex.get_file_size() == file_size
  end

  test "set_file_size/1" do
    file_size = 123

    assert %Uex{source: ""} |> Uex.set_file_size(file_size) == %Uex{
             source: "",
             meta: [file_size: file_size]
           }
  end

  test "get_upload_directory/1" do
    upload_directory = "/etc/lib"

    assert %Uex{source: "", opts: [upload_directory: upload_directory]}
           |> Uex.get_upload_directory() == upload_directory
  end

  test "set_upload_directory/1" do
    upload_directory = "/etc/lib"

    assert %Uex{source: ""} |> Uex.set_upload_directory(upload_directory) == %Uex{
             source: "",
             opts: [upload_directory: upload_directory]
           }
  end
end

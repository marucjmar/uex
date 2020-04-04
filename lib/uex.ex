defmodule Uex do
  @enforce_keys [:source]

  defstruct [:source, :file_path, :file_name, :tag, meta: [], opts: []]

  @type t :: %__MODULE__{
          source: any(),
          opts: keyword(),
          file_path: String.t(),
          file_name: String.t(),
          meta: keyword()
        }

  def new(source, opts \\ [])

  def new(source, opts) do
    name = Keyword.get(opts, :file_name)
    tag = Keyword.get(opts, :tag, :default)

    %__MODULE__{source: source, file_name: name, tag: tag}
  end

  def update_opts(%__MODULE__{opts: opts} = uex, key, value) do
    %__MODULE__{uex | opts: Keyword.update(opts, key, [value], &(&1 ++ [value]))}
  end

  def put_new_opts(%__MODULE__{opts: opts} = uex, key, value) do
    %__MODULE__{uex | opts: Keyword.put_new(opts, key, value)}
  end

  def put_opts(%__MODULE__{opts: opts} = uex, key, value) do
    %__MODULE__{uex | opts: Keyword.put(opts, key, value)}
  end

  def get_extension(%__MODULE__{meta: meta}) do
    Keyword.get(meta, :extension)
  end

  def set_extension(%__MODULE__{meta: meta} = uex, value) do
    %__MODULE__{uex | meta: Keyword.put(meta, :extension, value)}
  end

  def get_content_type(%__MODULE__{meta: meta}) do
    Keyword.get(meta, :content_type)
  end

  def set_content_type(%__MODULE__{meta: meta} = uex, value) do
    %__MODULE__{uex | meta: Keyword.put(meta, :content_type, value)}
  end

  def get_file_size(%__MODULE__{meta: meta}) do
    Keyword.get(meta, :file_size)
  end

  def set_file_size(%__MODULE__{meta: meta} = uex, value) do
    %__MODULE__{uex | meta: Keyword.put(meta, :file_size, value)}
  end
end

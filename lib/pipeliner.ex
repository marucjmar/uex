defmodule Uex.Pipeliner do
  defdelegate new(source, opts), to: Uex

  def pipe(_, _) do
  end

  defmacro stage(_name, do: _block) do
  end

  defmacro validate_extension do
  end

  defmacro validate_content_type do
  end

  defmacro validate_size do
  end

  defmacro persist do
  end

  defmacro add_transform do
  end
end

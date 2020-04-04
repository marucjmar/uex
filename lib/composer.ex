defmodule Uex.Composer do
  defstruct [:uex, middlewares: [], validators: [], errors: []]

  alias Uex.Preparer
  alias Uex.Validators.FileSize
  alias Uex.Validators.FileExtension
  alias Uex.Validators.FileContentType

  def compose(%Uex{} = uex) do
    %__MODULE__{uex: uex}
  end

  def add_middleware(%__MODULE__{} = model, middleware) do
    model
    |> Map.update(:middlewares, [middleware], &(&1 ++ [middleware]))
  end

  def validate_file_size(%__MODULE__{} = composer, opts) do
    composer
    |> put_validator(&FileSize.validate/2, opts)
  end

  def validate_extension(%__MODULE__{} = composer, opts) do
    composer
    |> put_validator(&FileExtension.validate/2, opts)
  end

  def validate_content_type(%__MODULE__{} = composer, opts) do
    composer
    |> put_validator(&FileContentType.validate/2, opts)
  end

  def add_version(%__MODULE__{} = composer, version_name, callback) do
    func = fn a, b, c ->
      mod = callback.(version_name, c, b)
      |> Preparer.prepare(b)

      [a] ++ [mod]
    end

    composer
    |> add_middleware(func)
  end

  def apply(%__MODULE__{} = composer) do
    composer
    |> apply_preparer()
    |> apply_validators()
    |> apply_middlewares()
  end

  defp apply_preparer(%__MODULE__{uex: uex} = composer) do
    %__MODULE__{composer | uex: Preparer.prepare(uex, []) }
  end

  def apply_validators(%__MODULE__{uex: uex, validators: validators} = composer) do
    validators
    |> Enum.map(fn {validator, opts} -> validator.(uex, opts) end)
    |> Enum.reduce(composer, fn
      :ok, acc -> acc
      reply, acc ->
        put_error(acc, reply)
    end)
  end

  defp apply_middlewares(%__MODULE__{errors: errors} = composer) when length(errors) > 0, do: composer

  defp apply_middlewares(%__MODULE__{uex: uex, middlewares: middlewares} = composer,  store_opts \\ []) do
    middlewares
    |> Enum.reduce(uex, fn
      callback, acc_module ->
        case callback.(acc_module, store_opts, uex) do
          reply when is_list(reply) ->
            reply |> List.flatten()
          %Uex{} = reply ->
            reply

          reply -> reply
        end

      _callback, reply ->
        reply
    end)
  end

  defp put_error(%__MODULE__{errors: errors} = composer, error) do
    %__MODULE__{composer | errors: errors ++ [error]}
  end

  defp put_validator(%__MODULE__{} = composer, callback, opts) do
    validator = {callback, opts}

    composer
    |> Map.update(:validators, [validator], &(&1 ++ [validator]))
  end
end

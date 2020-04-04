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
    func = fn acc, uex_opts, uex_source ->
      mod = callback.(version_name, uex_source, uex_opts)
      |> Preparer.prepare(uex_opts)

      [acc] ++ [mod]
    end

    composer
    |> add_middleware(func)
  end

  def apply(%__MODULE__{} = composer, uex_opts) do
    composer
    |> apply_preparer(uex_opts)
    |> apply_validators()
    |> apply_middlewares(uex_opts)
  end

  defp apply_preparer(%__MODULE__{uex: uex} = composer, uex_opts) do
    %__MODULE__{composer | uex: Preparer.prepare(uex, uex_opts) }
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

  defp apply_middlewares(%__MODULE__{errors: errors} = composer, _) when length(errors) > 0, do: composer

  defp apply_middlewares(%__MODULE__{uex: uex, middlewares: middlewares}, uex_opts) do
    middlewares
    |> Enum.reduce(uex, fn
      callback, acc_module ->
        case callback.(acc_module, uex_opts, uex) do
          reply when is_list(reply) ->
            reply |> List.flatten()
          %Uex{} = reply ->
            reply

          reply -> reply
        end
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

defmodule Uex.FileStorage do
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      alias Uex.Models.UploadFile
      alias Uex.Uploader
      alias Uex.Preparer

      otp_app = Keyword.get(opts, :otp_app) || raise "Missing `otp_app` option in store config"

      opts =
        opts
        |> Keyword.merge(Application.get_env(otp_app, __MODULE__, []))

      @adapter_module Keyword.fetch!(opts, :adapter)
      @adapter_opts @adapter_module.prepare_opts(opts)
      @source_resolver Keyword.get(opts, :source_resolver, Uex.SourceResolver)
      @response_handler Keyword.get(opts, :response_handler, Uex.ResponseHandler)
      @opts opts
      @name Keyword.get(opts, :name, Atom.to_string(__MODULE__))
      @middlewares Keyword.get(opts, :middlewares, [])
      @uex_opts_keys Keyword.get(opts, :uex_opts_keys, Uex.default_opts_keys()) ++
                       @adapter_module.uex_opts_keys()

      defstruct adapter_opts: @adapter_opts,
                adapter_module: @adapter_module,
                name: @name,
                source_resolver: @source_resolver

      def store(_source, override_opts \\ [])

      def store(%Uex{} = upload_model, override_opts) do
        uex_opts = Keyword.merge(Keyword.take(@opts, @uex_opts_keys), override_opts)

        upload_model
        |> Preparer.prepare(@source_resolver, uex_opts)
        |> apply_middlewares(override_opts)
        |> Uploader.store(%__MODULE__{})
        |> @response_handler.handle()
      end

      def store(%Uex.Composer{} = composer, override_opts) do
        uex_opts = Keyword.merge(Keyword.take(@opts, @uex_opts_keys), override_opts)

        composer
        |> Uex.Composer.apply(uex_opts, %__MODULE__{})
        |> apply_middlewares(override_opts)
        |> Uploader.store(%__MODULE__{})
        |> @response_handler.handle()
      end

      def store_all(upload_model, override_opts \\ [])

      def store_all(%Uex{} = upload_model, override_opts) do
        uex_opts = Keyword.merge(Keyword.take(@opts, @uex_opts_keys), override_opts)

        upload_model
        |> Preparer.prepare(@source_resolver, uex_opts)
        |> apply_middlewares(override_opts)
        |> Uploader.store_all(%__MODULE__{})
        |> @response_handler.handle()
      end

      def store_all(%Uex.Composer{} = composer, override_opts) do
        uex_opts = Keyword.merge(Keyword.take(@opts, @uex_opts_keys), override_opts)

        composer
        |> Uex.Composer.apply(uex_opts, %__MODULE__{})
        |> apply_middlewares(override_opts)
        |> Uploader.store_all(%__MODULE__{})
        |> @response_handler.handle()
      end

      def store_all([%Uex{} | _] = upload_models, override_opts) do
        uex_opts = Keyword.merge(Keyword.take(@opts, @uex_opts_keys), override_opts)

        upload_models
        |> Enum.map(&Preparer.prepare(&1, @source_resolver, uex_opts))
        |> apply_middlewares(override_opts)
        |> Uploader.store_all(%__MODULE__{})
        |> @response_handler.handle()
      end

      defp apply_middlewares(models, store_opts) do
        (@middlewares ++ Keyword.get(store_opts, :middlewares, []))
        |> Enum.reduce(models, fn
          _, {:error, _} = reply ->
            reply

          callback, acc_module ->
            callback.(acc_module, store_opts)
            |> case do
              :ok -> acc_module
              {:error, _} = reply -> reply
              reply -> reply
            end
        end)
      end

      def url_for_resource(resource) do
        @adapter_module.url_for_resource(resource, %__MODULE__{})
      end
    end
  end
end

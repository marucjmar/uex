defmodule Uex.FileStorage do
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      alias Uex.Models.UploadFile
      alias Uex.Uploader

      otp_app = Keyword.get(opts, :otp_app) || raise "Missing `otp_app` option in store config"

      opts =
        opts
        |> Keyword.merge(Application.get_env(otp_app, __MODULE__))

      @adapter_module Keyword.fetch!(opts, :adapter)
      @adapter_opts @adapter_module.prepare_opts(opts)
      @preparer Keyword.get(opts, :preparer, Uex.Preparer)
      @response_handler Keyword.get(opts, :response_handler, Uex.ResponseHandler)
      @opts opts
      @name Keyword.get(opts, :name, Atom.to_string(__MODULE__))
      @middlewares Keyword.get(opts, :middlewares, [])
      @uex_opts Keyword.get(opts, :uex_opts, Uex.default_opts()) ++ @adapter_module.uex_opts()

      defstruct adapter_opts: @adapter_opts,
                adapter_module: @adapter_module,
                name: @name

      def store(_source, override_opts \\ [])

      def store(%Uex{} = upload_model, override_opts) do
        uex_opts = Keyword.merge(Keyword.take(@opts, @uex_opts), override_opts)

        upload_model
        |> @preparer.prepare(uex_opts)
        |> apply_middlewares(override_opts)
        |> Uploader.store(%__MODULE__{})
        |> @response_handler.handle()
      end

      def store(%Uex.Composer{} = composer, override_opts) do
        uex_opts = Keyword.merge(Keyword.take(@opts, @uex_opts), override_opts)

        composer
        |> Uex.Composer.apply(uex_opts)
        |> apply_middlewares(override_opts)
        |> Uploader.store(%__MODULE__{})
        |> @response_handler.handle()
      end

      def store_all(upload_model, override_opts \\ [])

      def store_all(%Uex{} = upload_model, override_opts) do
        uex_opts = Keyword.merge(Keyword.take(@opts, @uex_opts), override_opts)

        upload_model
        |> @preparer.prepare(uex_opts)
        |> apply_middlewares(override_opts)
        |> Uploader.store_all(%__MODULE__{})
        |> @response_handler.handle()
      end

      def store_all(%Uex.Composer{} = composer, override_opts) do
        uex_opts = Keyword.merge(Keyword.take(@opts, @uex_opts), override_opts)

        composer
        |> Uex.Composer.apply(uex_opts)
        |> apply_middlewares(override_opts)
        |> Uploader.store_all(%__MODULE__{})
        |> @response_handler.handle()
      end

      def store_all([%Uex{} | _] = upload_models, override_opts) do
        uex_opts = Keyword.merge(Keyword.take(@opts, @uex_opts), override_opts)

        upload_models
        |> Enum.map(&@preparer.prepare(&1, uex_opts))
        |> apply_middlewares(override_opts)
        |> Uploader.store_all(%__MODULE__{})
        |> @response_handler.handle()
      end

      defp apply_middlewares(models, store_opts) do
        (@middlewares ++ Keyword.get(store_opts, :middlewares, []))
        |> Enum.reduce(models, fn
          callback, acc_module ->
            callback.(acc_module, store_opts)
            |> List.flatten()
        end)
      end

      def url_for_resource(resource) do
        @adapter_module.url_for_resource(resource, %__MODULE__{})
      end
    end
  end
end

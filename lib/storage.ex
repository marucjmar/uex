defmodule Uex.FileStorage do
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      alias Uex.Models.UploadFile
      alias Uex.Uploader

      otp_app = Keyword.get(opts, :otp_app) || raise "Missing `otp_app` option in store config"

      opts =
        Application.get_env(otp_app, __MODULE__)
        |> Keyword.merge(opts)

      @adapter_module Keyword.fetch!(opts, :adapter)
      @adapter_opts @adapter_module.prepare_opts(opts)
      @preparer Keyword.get(opts, :preparer, Uex.Preparer)
      @response_handler Keyword.get(opts, :response_handler, Uex.ResponseHandler)
      @opts opts
      @name Keyword.get(opts, :name, Atom.to_string(__MODULE__))
      @middlewares Keyword.get(opts, :middlewares, [])

      defstruct adapter_opts: @adapter_opts,
                adapter_module: @adapter_module,
                name: @name

      def store(_source, override_opts \\ [])

      def store(%Uex{} = upload_model, override_opts) do
        store_opts = Keyword.merge(unquote(opts), override_opts)

        upload_model
        |> @preparer.prepare(store_opts)
        |> apply_middlewares(store_opts)
        |> Uploader.store(%__MODULE__{}, store_opts)
        |> @response_handler.handle()
      end

      def store(%Uex.Composer{} = composer, override_opts) do
        store_opts = Keyword.merge(unquote(opts), override_opts)

        composer
        |> Uex.Composer.apply()
        |> apply_middlewares(store_opts)
        |> Uploader.store(%__MODULE__{}, store_opts)
        |> @response_handler.handle()
      end

      def store_all(upload_model, override_opts \\ [])

      def store_all(%Uex{} = upload_model, override_opts) do
        store_opts = Keyword.merge(unquote(opts), override_opts)

        upload_model
        |> @preparer.prepare(store_opts)
        |> apply_middlewares(store_opts)
        |> Uploader.store_all(%__MODULE__{}, store_opts)
        |> @response_handler.handle()
      end

      def store_all(%Uex.Composer{} = composer, override_opts) do
        store_opts = Keyword.merge(unquote(opts), override_opts)

        composer
        |> Uex.Composer.apply()
        |> apply_middlewares(store_opts)
        |> Uploader.store_all(%__MODULE__{}, store_opts)
        |> @response_handler.handle()
      end

      def store_all([%Uex{} | _] = upload_models, override_opts) do
        store_opts = Keyword.merge(unquote(opts), override_opts)

        upload_models
        |> Enum.map(&@preparer.prepare(&1, store_opts))
        |> apply_middlewares(store_opts)
        |> Uploader.store_all(%__MODULE__{}, store_opts)
        |> @response_handler.handle()
      end

      defp apply_middlewares(models, store_opts) do
        (@middlewares ++ Keyword.get(store_opts, :middlewares, []))
        |> Enum.reduce(models, fn
          callback, acc_module ->
            callback.(acc_module, store_opts)
            |> List.flatten()

          _callback, reply ->
            reply
        end)
      end
    end
  end
end

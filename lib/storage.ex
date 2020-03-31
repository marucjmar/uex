defmodule Uex.FileStorage do
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      alias Uex.Models.UploadFile
      alias Uex.Uploader

      @adapter_module Keyword.fetch!(opts, :adapter)
      @adapter_opts @adapter_module.prepare_opts(opts)
      @preparer Keyword.get(opts, :preparer, Uex.Preparer)
      @response_handler Keyword.get(opts, :response_handler, Uex.ResponseHandler)
      @opts opts
      @name Keyword.get(opts, :name, Atom.to_string(__MODULE__))
      @middlewares Keyword.get(opts, :middlewares, Uex.FileStorage.default_middlewares())

      defstruct adapter_opts: @adapter_opts,
                adapter_module: @adapter_module,
                name: @name

      def store(%Uex{} = upload_model, override_opts \\ []) do
        upload_model
        |> _store(override_opts, &Uploader.store/3)
      end

      def store_all(%Uex{} = upload_model, override_opts \\ []) do
        upload_model
        |> _store(override_opts, &Uploader.store_all/3)
      end

      defp _store(%Uex{} = upload_model, override_opts, uplader_func) do
        store_opts = Keyword.merge(unquote(opts), override_opts)

        upload_model
        |> Map.update(:opts, @opts[:default_opts], &Keyword.merge(&1, @opts[:default_opts]))
        |> @preparer.prepare(store_opts)
        |> apply_middlewares(store_opts)
        |> uplader_func.(%__MODULE__{}, store_opts)
        |> @response_handler.handle()
      end

      defp apply_middlewares(%Uex{middlewares: middlewares} = module, store_opts) do
        (@middlewares ++ middlewares)
        |> Enum.reduce(module, fn
          callback, %Uex{} = acc_module ->
            case callback.(acc_module, store_opts) do
              %Uex{} = model ->
                model

              reply ->
                reply
            end

          _callback, reply ->
            reply
        end)
      end

      # alias Uex.Models.UploadedFile

      # def recreate_url(storage, %UploadedFile{} = resource) do
      #   @adapter_module.url_for(resource, @opts)
      # end

      # def move_resource_to(%UploadedFile{} = resource, storage) do
      #   @adapter_module.move_resource(resource, @opts)
      # end

      # def copy_resource_to(%UploadedFile{} = resource, storage) do
      #   @adapter_module.copy_resource(resource, @opts)
      # end
    end
  end

  def default_middlewares() do
    [&Uex.Middlewares.CreateOriginalFile.call/2]
  end
end

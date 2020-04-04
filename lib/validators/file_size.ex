defmodule Uex.Validators.FileSize do
  def validate(%Uex{} = model, opts) do
    opts
    |> Enum.reduce(model, fn
      opt, %Uex{} = model ->
        check(opt, model)
      _opt, reply ->
        reply
    end)
  end

  defp check({:error, _} = reply, _), do: reply

  defp check({:min, value}, %Uex{} = uex) do
    file_size = Uex.get_file_size(uex)

    if (file_size >= value) do
      :ok
    else
      {:error, :file_size_is_too_small}
    end
  end

  defp check({:max, value}, %Uex{} = uex) do
    file_size = Uex.get_file_size(uex)

    if (file_size <= value) do
      :ok
    else
      {:error, :file_size_is_too_large}
    end
  end
end

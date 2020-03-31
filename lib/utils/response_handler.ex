defmodule Uex.ResponseHandler do
  def handle({:error, _} = error) do
    error
  end

  def handle({:ok, _} = result) do
    result
  end
end

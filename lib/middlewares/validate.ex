# defmodule Uex.Middlewares.Validate do
#   import Mogrify

#   alias Uex.Models.UploadFile

#   @extensions [".jpg", ".png"]
#   @max_file_size 500_000

#   def call(%Uex{} = model) do
#     model
#     |> validate_extension(@extensions)
#     |> validate_max_file_size(@max_file_size)
#   end

#   def validate_extension(%Uex{extension: extension} = model)
#       when extension in @extensions do
#     model
#   end

#   def validate_max_file_size(%Uex{size: size} = model)
#       when size <= @max_file_size do
#     model
#   end

#   def validate_max_file_size(reply), do: reply
# end

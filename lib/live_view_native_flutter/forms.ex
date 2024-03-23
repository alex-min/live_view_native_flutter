defmodule LiveViewNativeFlutter.Forms do
  @doc """
    Extract the Phoenix forms errors to be usable by flutter in your live view

    ## Example

        <TextField name="title" errors={form_error(@form[:title])} value="" />
  """
  def form_error(%Phoenix.HTML.FormField{errors: errors}) do
    Enum.map(errors, fn err ->
      case err do
        {message, options} ->
          %{message: message, options: options |> :maps.from_list()}

        _ ->
          err
      end
    end)
    |> Phoenix.json_library().encode!
  end
end

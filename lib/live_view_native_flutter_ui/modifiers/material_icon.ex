defmodule LiveViewNativeFlutterUi.Modifiers.MaterialIcon do
  use LiveViewNativePlatform.Modifier

  alias LiveViewNativeFlutterUi.Types.MaterialIcon

  modifier_schema "material_icon" do
    field(:icon, MaterialIcon)
  end

  def params(params) do
    with {:ok, _} <- MaterialIcon.cast(params) do
      [icon: params]
    else
      _ ->
        params
    end
  end
end

defmodule LiveViewNativeFlutterUi do
  use LiveViewNativePlatform

  def platforms,
    do: [
      LiveViewNativeFlutterUi.Platform
    ]
end

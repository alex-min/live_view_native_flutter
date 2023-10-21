defmodule LiveViewNativeFlutter do
  use LiveViewNativePlatform

  def platforms,
    do: [
      LiveViewNativeFlutter.Platform
    ]
end

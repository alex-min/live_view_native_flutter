defmodule LiveViewNative.Flutter.Component do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      import LiveViewNative.Component, only: [sigil_LVN: 2]
      import LiveViewNative.Flutter.Component, only: [sigil_FLUTTER: 2]
    end
  end

  defmacro sigil_FLUTTER(doc, modifiers) do
    IO.warn("~FLUTTER is deprecated and will be removed for v0.4.0 Please change to ~LVN")

    quote do
      sigil_LVN(unquote(doc), unquote(modifiers))
    end
  end
end

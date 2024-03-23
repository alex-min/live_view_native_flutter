defmodule LiveViewNativeFlutter do
  @moduledoc false

  use LiveViewNative,
    format: :flutter,
    component: LiveViewNative.Flutter.Component,
    module_suffix: :Flutter,
    template_engine: LiveViewNative.Engine
end

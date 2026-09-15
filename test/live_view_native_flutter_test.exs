defmodule LiveViewNativeFlutterTest do
  use ExUnit.Case, async: true

  test "registers the current LiveView Native template engine" do
    assert %LiveViewNative.Flutter{template_engine: LiveViewNative.Template.Engine} =
             struct(LiveViewNative.Flutter)
  end
end

defmodule LiveViewNativeFlutterUi.Platform do
  defstruct [
    :app_name,
    :os_name,
    :os_version,
    :simulator_opts,
    :user_interface_idiom,
    custom_modifiers: []
  ]

  defimpl LiveViewNativePlatform.Kit do
    require Logger

    def compile(struct) do
      LiveViewNativePlatform.Env.define(:flutterui,
        custom_modifiers: struct.custom_modifiers,
        render_macro: :sigil_FLUTTERUI,
        otp_app: :live_view_native_flutter_ui
      )
    end
  end
end

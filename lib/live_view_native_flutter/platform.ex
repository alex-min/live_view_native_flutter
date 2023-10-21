defmodule LiveViewNativeFlutter.Platform do
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
      LiveViewNativePlatform.Env.define(:flutter,
        custom_modifiers: struct.custom_modifiers,
        render_macro: :sigil_FLUTTER,
        otp_app: :live_view_native_flutter
      )
    end
  end
end

defmodule LiveViewNativeFlutter.Dart do
  @moduledoc ~S'''
  Provides commands for executing Flutter operations on the client.

  Inspired & partially copied from Phoenix.LiveView.JS
  '''

  alias LiveViewNativeFlutter.Dart
  @default_transition_time 200

  defstruct ops: []

  @opaque t :: %__MODULE__{}

  defimpl Phoenix.HTML.Safe, for: LiveViewNativeFlutter.Dart do
    def to_iodata(%LiveViewNativeFlutter.Dart{} = js) do
      Phoenix.HTML.Engine.html_escape(Phoenix.json_library().encode!(js.ops))
    end
  end

  @doc """
  Pushes an event to the server.

    * `event` - The string event name to push.

  ## Options

    * `:target` - The selector or component ID to push to. This value will
      overwrite any `phx-target` attribute present on the element.

  ## Examples

      <ElevatedButton phx-click={Dart.push("clicked")}>click me!</ElevatedButton>
  """
  def push(event) when is_binary(event) do
    push(%Dart{}, event, [])
  end

  @doc "See `push/1`."
  def push(event, opts) when is_binary(event) and is_list(opts) do
    push(%Dart{}, event, opts)
  end

  def push(%Dart{} = exec, event) when is_binary(event) do
    push(exec, event, [])
  end

  @doc "See `push/1`."
  def push(%Dart{} = exec, event, opts) when is_binary(event) and is_list(opts) do
    opts =
      opts
      |> validate_keys(:push, [:target, :value])
      |> put_target()
      |> put_value()

    put_op(exec, "push", Enum.into(opts, %{event: event}))
  end

  @doc """
  Switches the app theme, the app theme is not saved locally, please see save_theme for saving the current theme.

    * `theme` (optional) - The theme to switch to (the default theme is named "default")
    * `mode` - light / dark / system The mode to switch the theme to (the default mode is "light")

  ## Examples

      Dart.switch_theme("dark")
      Dart.switch_theme("default", "dark")
      Dart.switch_theme("default", "system")
  """
  def switch_theme(mode) when is_binary(mode) do
    %Dart{} |> switch_theme("default", mode)
  end

  def switch_theme(theme, mode) when is_binary(theme) and is_binary(mode) do
    %Dart{} |> switch_theme(theme, mode)
  end

  def switch_theme(%Dart{} = exec, mode) when is_binary(mode) do
    switch_theme(exec, "default", mode)
  end

  def switch_theme(%Dart{} = exec, theme, mode)
      when is_binary(theme) and is_binary(mode) do
    put_op(exec, "switchTheme", %{theme: theme, mode: mode})
  end

  defp class_names(nil), do: []

  defp class_names(names) do
    String.split(names, " ")
  end

  @doc """
  Hides elements.

  ## Options

    * `:to` - The optional DOM selector to hide.
      Defaults to the interacted element.
    * `:transition` - The string of classes to apply before hiding or
      a 3-tuple containing the transition class, the class to apply
      to start the transition, and the ending transition class, such as:
      `{"ease-out duration-300", "opacity-100", "opacity-0"}`
    * `:time` - The time to apply the transition from `:transition`.
      Defaults #{@default_transition_time}

  During the process, the following events will be dispatched to the hidden elements:

    * When the action is triggered on the client, `phx:hide-start` is dispatched.
    * After the time specified by `:time`, `phx:hide-end` is dispatched.

  ## Examples

      <Container id="item">My Item</Container>

      <ElevatedButton phx-click={JS.hide(to: "#item")}>
        hide!
      </ElevatedButton>

      <ElevatedButton phx-click={JS.hide(to: "#item", transition: "fade-out-scale")}>
        hide fancy!
      </ElevatedButton>
  """
  def hide(opts \\ [])
  def hide(%Dart{} = dart), do: hide(dart, [])
  def hide(opts) when is_list(opts), do: hide(%Dart{}, opts)

  @doc "See `hide/1`."
  def hide(dart, opts) when is_list(opts) do
    opts = validate_keys(opts, :hide, [:to, :transition, :time])
    transition = transition_class_names(opts[:transition])
    time = opts[:time] || @default_transition_time

    put_op(dart, "hide",
      to: opts[:to],
      transition: transition,
      time: time
    )
  end

  def show(opts \\ [])
  def show(%Dart{} = dart), do: show(dart, [])
  def show(opts) when is_list(opts), do: show(%Dart{}, opts)

  @doc "See `show/1`."
  def show(dart, opts) when is_list(opts) do
    opts = validate_keys(opts, :show, [:to, :transition, :time])
    transition = transition_class_names(opts[:transition])
    time = opts[:time] || @default_transition_time

    put_op(dart, "show",
      to: opts[:to],
      transition: transition,
      time: time
    )
  end

  @doc """
  Saves the current theme in the local storage of the app.
  When the app boots, the theme stored will be used

  ## Examples

      Dart.save_current_theme()
  """
  def save_current_theme(%Dart{} = exec) do
    put_op(exec, "saveCurrentTheme", %{})
  end

  def save_current_theme() do
    put_op(%Dart{}, "saveCurrentTheme", %{})
  end

  defp put_op(%Dart{ops: ops} = js, kind, args) do
    %Dart{js | ops: ops ++ [[kind, args]]}
  end

  defp transition_class_names(nil), do: [[], [], []]

  defp transition_class_names(transition) when is_binary(transition),
    do: [class_names(transition), [], []]

  defp transition_class_names({transition, tstart, tend})
       when is_binary(tstart) and is_binary(transition) and is_binary(tend) do
    [class_names(transition), class_names(tstart), class_names(tend)]
  end

  defp validate_keys(opts, kind, allowed_keys) do
    for key <- Keyword.keys(opts) do
      if key not in allowed_keys do
        raise ArgumentError, """
        invalid option for #{kind}
        Expected keys to be one of #{inspect(allowed_keys)}, got: #{inspect(key)}
        """
      end
    end

    opts
  end

  defp put_value(opts) do
    case Keyword.fetch(opts, :value) do
      {:ok, val} when is_map(val) -> Keyword.put(opts, :value, val)
      {:ok, val} -> raise ArgumentError, "push :value expected to be a map, got: #{inspect(val)}"
      :error -> opts
    end
  end

  defp put_target(opts) do
    case Keyword.fetch(opts, :target) do
      {:ok, %Phoenix.LiveComponent.CID{cid: cid}} -> Keyword.put(opts, :target, cid)
      {:ok, selector} -> Keyword.put(opts, :target, selector)
      :error -> opts
    end
  end
end

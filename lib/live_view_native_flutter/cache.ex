defmodule LiveViewNative.Flutter.Cache do
  @moduledoc """
  Components for declaring client-side Flutter route cache policy.

  The manifest is metadata only. It authorizes the native client to show a
  previously rendered route while the normal HTTP bootstrap and LiveView join
  obtain authoritative content.
  """

  use LiveViewNative.Component, format: :flutter

  @maximum_route_count 16
  @scopes ~w(public user memory)
  @strategies ~w(stale-while-revalidate)
  @priorities ~w(normal high)

  attr(:version, :string, required: true)
  attr(:scope, :any, required: true)
  attr(:identity, :string, default: nil)
  attr(:strategy, :any, default: :"stale-while-revalidate")
  attr(:routes, :list, required: true)

  @doc """
  Declares the routes a Flutter client may cache.

  Routes must be same-origin absolute paths represented as maps containing
  `:href` and a positive `:max_age` in seconds. They may optionally set
  `:priority` to `:normal` or `:high`.
  """
  def cache_manifest(assigns, _interface) do
    version = required_string!(assigns.version, :version)
    scope = enum_string!(assigns.scope, @scopes, :scope)
    strategy = enum_string!(assigns.strategy, @strategies, :strategy)
    identity = optional_string(assigns.identity)

    if scope == "user" and is_nil(identity) do
      raise ArgumentError, "user-scoped cache manifests require a non-empty identity"
    end

    routes = normalize_routes!(assigns.routes)

    assigns =
      assigns
      |> assign(:version, version)
      |> assign(:scope, scope)
      |> assign(:strategy, strategy)
      |> assign(:identity, identity)
      |> assign(:routes, routes)

    ~LVN"""
    <live-cache-manifest version={@version} scope={@scope} identity={@identity} strategy={@strategy}>
      <%= for route <- @routes do %>
        <live-cache-route href={route.href} max-age={route.max_age} priority={route.priority} />
      <% end %>
    </live-cache-manifest>
    """
  end

  defp normalize_routes!(routes) when is_list(routes) do
    if length(routes) > @maximum_route_count do
      raise ArgumentError, "cache manifests support at most #{@maximum_route_count} routes"
    end

    normalized = Enum.map(routes, &normalize_route!/1)

    duplicates =
      normalized
      |> Enum.frequencies_by(& &1.href)
      |> Enum.filter(fn {_href, count} -> count > 1 end)

    if duplicates != [] do
      raise ArgumentError, "cache manifest routes must be unique"
    end

    normalized
  end

  defp normalize_routes!(_routes) do
    raise ArgumentError, "cache manifest routes must be a list"
  end

  defp normalize_route!(route) when is_map(route) do
    href = route |> fetch_route_value!(:href) |> valid_route!()
    max_age = route |> fetch_route_value!(:max_age) |> positive_integer!(:max_age)
    priority = route |> route_value(:priority, :normal) |> enum_string!(@priorities, :priority)

    %{href: href, max_age: max_age, priority: priority}
  end

  defp normalize_route!(_route) do
    raise ArgumentError, "each cache route must be a map"
  end

  defp valid_route!(href) when is_binary(href) do
    uri = URI.parse(href)

    if String.starts_with?(href, "/") and
         not String.starts_with?(href, "//") and
         is_nil(uri.scheme) and
         is_nil(uri.host) and
         is_nil(uri.fragment) do
      href
    else
      raise ArgumentError, "cache route href must be a same-origin absolute path"
    end
  end

  defp valid_route!(_href) do
    raise ArgumentError, "cache route href must be a string"
  end

  defp positive_integer!(value, _name) when is_integer(value) and value > 0, do: value

  defp positive_integer!(_value, name) do
    raise ArgumentError, "cache route #{name} must be a positive integer"
  end

  defp required_string!(value, _name) when is_binary(value) and byte_size(value) > 0,
    do: value

  defp required_string!(_value, name) do
    raise ArgumentError, "cache manifest #{name} must be a non-empty string"
  end

  defp optional_string(nil), do: nil
  defp optional_string(""), do: nil
  defp optional_string(value) when is_binary(value), do: value

  defp optional_string(_value) do
    raise ArgumentError, "cache manifest identity must be a string"
  end

  defp enum_string!(value, allowed, name) do
    normalized = if is_atom(value), do: Atom.to_string(value), else: value

    if normalized in allowed do
      normalized
    else
      raise ArgumentError, "unsupported cache manifest #{name}: #{inspect(value)}"
    end
  end

  defp fetch_route_value!(route, key) do
    case route_value(route, key, :missing) do
      :missing -> raise ArgumentError, "cache route requires #{key}"
      value -> value
    end
  end

  defp route_value(route, key, default) do
    Map.get(route, key, Map.get(route, Atom.to_string(key), default))
  end
end

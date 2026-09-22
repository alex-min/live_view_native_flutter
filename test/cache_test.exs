defmodule LiveViewNative.Flutter.CacheTest do
  use ExUnit.Case, async: true

  import LiveViewNative.Component, only: [sigil_LVN: 2]
  import LiveViewNative.Flutter.Cache
  import LiveViewNativeTest

  test "renders a deterministic user-scoped manifest" do
    assigns = %{
      identity: "opaque-user",
      routes: [
        %{href: "/dashboard", max_age: 300, priority: :high},
        %{href: "/accounts", max_age: 600}
      ]
    }

    rendered =
      rendered_to_string(~LVN"""
      <.cache_manifest
        version="finance-v1"
        scope={:user}
        identity={@identity}
        routes={@routes}
      />
      """)

    assert rendered =~
             ~s|<live-cache-manifest version="finance-v1" scope="user" identity="opaque-user" strategy="stale-while-revalidate">|

    assert rendered =~
             ~s|<live-cache-route href="/dashboard" max-age="300" priority="high"></live-cache-route>|

    assert rendered =~
             ~s|<live-cache-route href="/accounts" max-age="600" priority="normal"></live-cache-route>|

    assert :binary.match(rendered, ~s|href="/dashboard"|) <
             :binary.match(rendered, ~s|href="/accounts"|)
  end

  test "escapes manifest and route attributes" do
    assigns = %{
      routes: [%{href: "/search?q=one&kind=two", max_age: 60}]
    }

    rendered =
      rendered_to_string(~LVN"""
      <.cache_manifest version="public-v1" scope={:public} routes={@routes} />
      """)

    assert rendered =~ ~s|href="/search?q=one&amp;kind=two"|
  end

  test "requires an identity for user scope" do
    assigns = %{routes: []}

    assert_raise ArgumentError, ~r/require a non-empty identity/, fn ->
      rendered_to_string(~LVN"""
      <.cache_manifest version="1" scope={:user} routes={@routes} />
      """)
    end
  end

  test "rejects unsafe routes" do
    for href <- ["https://example.com/accounts", "//example.com/accounts", "accounts", "/a#b"] do
      assigns = %{routes: [%{href: href, max_age: 60}]}

      assert_raise ArgumentError, ~r/same-origin absolute path/, fn ->
        rendered_to_string(~LVN"""
        <.cache_manifest version="1" scope={:public} routes={@routes} />
        """)
      end
    end
  end

  test "rejects duplicate and excessive routes" do
    assigns = %{
      duplicate_routes: [
        %{href: "/accounts", max_age: 60},
        %{href: "/accounts", max_age: 120}
      ],
      excessive_routes: Enum.map(0..16, fn index -> %{href: "/route-#{index}", max_age: 60} end)
    }

    assert_raise ArgumentError, ~r/must be unique/, fn ->
      rendered_to_string(~LVN"""
      <.cache_manifest version="1" scope={:public} routes={@duplicate_routes} />
      """)
    end

    assert_raise ArgumentError, ~r/at most 16 routes/, fn ->
      rendered_to_string(~LVN"""
      <.cache_manifest version="1" scope={:public} routes={@excessive_routes} />
      """)
    end
  end

  test "rejects malformed route policy" do
    invalid_routes = [
      %{},
      %{href: "/accounts", max_age: 0},
      %{href: "/accounts", max_age: "later"},
      %{href: "/accounts", max_age: 60, priority: :urgent}
    ]

    for route <- invalid_routes do
      assigns = %{routes: [route]}

      assert_raise ArgumentError, fn ->
        rendered_to_string(~LVN"""
        <.cache_manifest version="1" scope={:public} routes={@routes} />
        """)
      end
    end
  end

  test "rejects unsupported manifest policy" do
    assigns = %{routes: []}

    assert_raise ArgumentError, ~r/unsupported cache manifest scope/, fn ->
      rendered_to_string(~LVN"""
      <.cache_manifest version="1" scope={:device} routes={@routes} />
      """)
    end

    assert_raise ArgumentError, ~r/unsupported cache manifest strategy/, fn ->
      rendered_to_string(~LVN"""
      <.cache_manifest
        version="1"
        scope={:public}
        strategy={:cache_first}
        routes={@routes}
      />
      """)
    end
  end
end

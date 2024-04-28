# Flagship

Flagship acts as an interface and tooling for working with launchdarkly feature flags.

## Installation

The package can be installed by adding `flagship` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:flagship, "~> 0.1.6"}
  ]
end
```

Start up the application (in your application.ex file):
```elixir
children =
  [
    {Flagship.FeatureFlags, name: Flagship.FeatureFlags},
    ...
  ]
```

And configure the application (in config.exs or similar):
```elixir
config :flagship,
  ld_sdk_key: "<ENTER SDK KEY HERE>", # required
  default_context: %{}, # optional - expects a map that represents a launchdarkly context
  ld_client_options: %{ # all values are optional
    file_datasource: true,
    send_events: false,
    file_paths: ['launch_darkly_local_config.json'],
    feature_store: :ldclient_storage_map,
    file_auto_update: true,
    file_poll_interval: 1000
  }
```

And configure for your test environment (in text.exs):
```elixir
config :flagship,
  ld_sdk_key: "test key",
  ld_client_options: %{
    datasource: :testdata,
    send_events: false,
    feature_store: :ldclient_storage_map
  }
```

## Running tests on this project
The tests rely on a test double for the LaunchDarkly implementation.
```elixir
FLAGSHIP_IMPLEMENTATION=Flagship.LaunchDarklyTest mix test
```



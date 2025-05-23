defmodule Flagship.LaunchDarkly.Interface do
  @moduledoc """
  Behaviours for the LaunchDarkly SDK
  """

  # ldclient
  @callback identify(user :: map()) :: :ok
  @callback initialized(tag :: atom()) :: boolean()
  @callback start_instance(sdk_key :: binary(), opts :: map()) :: :ok | {:error, atom(), term()}
  @callback stop_all_instances() :: :ok
  @callback variation(flag_name :: binary(), context :: map(), fallback :: term()) :: term()
  @callback track(event_name :: binary(), context :: map(), data :: map()) :: :ok

  # ldclient_testdata
  @callback test_update(flag_builder :: term()) :: :ok
  @callback test_flag(flag_name :: binary()) :: {:ok, flag_builder :: term()}

  # ldclient_flagbuilder
  @callback set_value(is_on? :: boolean(), flag :: map()) :: flag_builder :: term()
  @callback value_for_all(value :: term(), flag_builder :: term()) :: flag_builder :: term()

  # ldclient_user
  @callback new_user(user :: map()) :: user :: term()
end

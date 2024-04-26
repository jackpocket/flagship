defmodule Flagship.LaunchDarkly do
  @moduledoc """
  Acts as the interface for the LaunchDarkly SDK
  """
  @behaviour Flagship.LaunchDarkly.Interface

  @impl true
  def initialized(tag), do: :ldclient.initialized(tag)

  @impl true
  def start_instance(sdk_key, opts), do: :ldclient.start_instance(String.to_charlist(sdk_key), opts)

  @impl true
  def variation(flag_name, context, fallback), do: :ldclient.variation(flag_name, context, fallback)

  @impl true
  def test_update(flag_builder), do: :ldclient_testdata.update(flag_builder)

  @impl true
  def test_flag(flag_name), do: :ldclient_testdata.flag(String.to_charlist(flag_name))

  @impl true
  def set_value(is_on?, flag), do: :ldclient_flagbuilder.on(is_on?, flag)

  @impl true
  def value_for_all(value, flag), do: :ldclient_flagbuilder.value_for_all(value, flag)
end

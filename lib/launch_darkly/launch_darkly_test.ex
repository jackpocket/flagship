defmodule Flagship.LaunchDarklyTest do
  @moduledoc """
  Acts as the test double for the LaunchDarkly SDK
  """
  @behaviour Flagship.LaunchDarkly.Interface

  @impl true
  def initialized(false), do: false
  def initialized(_tag), do: true

  @impl true
  def start_instance(_sdk_key, _opts), do: :ok

  @impl true
  def variation(_flag_name, _context, fallback), do: fallback

  @impl true
  def test_update(_flag_builder), do: :ok

  @impl true
  def test_flag(flag_name), do: {:ok, flag(flag_name)}

  @impl true
  def set_value(is_on?, %{key: flag_name}), do: flag_builder(flag_name, is_on?)

  @impl true
  def value_for_all(value, flag_builder), do: Map.put(flag_builder, :on, value)

  @impl true
  def identify(_user), do: :ok

  @impl true
  def stop_all_instances(), do: :ok

  @impl true
  def new_user(user), do: user

  @impl true
  def track(event_name, context, data), do: :ok

  @impl true
  def track(event_name, context, data, tag), do: :ok

  #### Private functions ####

  defp flag(flag_name) do
    %{
      fallthrough_variation: 0,
      key: flag_name,
      off_variation: 1,
      on: true,
      variations: [true, false]
    }
  end

  defp flag_builder(flag_name, value) do
    %{
      fallthrough_variation: 0,
      key: flag_name,
      off_variation: 1,
      on: value,
      variations: [true, false]
    }
  end
end
